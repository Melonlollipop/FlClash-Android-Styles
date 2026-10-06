import 'package:fl_clash/common/interface_style.dart';
import 'package:fl_clash/common/navigator.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  void setViewWidth(double width) {
    container.read(viewSizeProvider.notifier).value = Size(width, 900);
  }

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => BaseNavigator.push(
                  context,
                  const Scaffold(body: Text('pushed page')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('BaseNavigator.push', () {
    testWidgets('uses the fading desktop route on a wide view', (tester) async {
      setViewWidth(1400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FadeTransition), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('uses the page route on a mobile view', (tester) async {
      setViewWidth(400);
      await pumpHost(tester);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('pops back to the origin', (tester) async {
      setViewWidth(1400);
      await pumpHost(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('pushed page'));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('page animation on a mobile view', () {
    Future<void> pushHalfway(
      WidgetTester tester,
      TabAnimation pageAnimation,
    ) async {
      setViewWidth(400);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData().withInterfaceStyle(
              InterfaceStyleTheme(pageAnimation: pageAnimation),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                key: const ValueKey('home'),
                body: TextButton(
                  onPressed: () => BaseNavigator.push(
                    context,
                    const Scaffold(key: ValueKey('page'), body: Text('page')),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
    }

    double left(WidgetTester tester, String key) {
      return tester.getTopLeft(find.byKey(ValueKey(key))).dx;
    }

    testWidgets('slides the page in and the page below aside', (tester) async {
      await pushHalfway(tester, TabAnimation.slide);

      expect(find.byType(CommonPageTransition), findsOneWidget);
      expect(left(tester, 'page'), inExclusiveRange(0, 800));
      expect(left(tester, 'home'), inExclusiveRange(-800 / 3, 0));

      await tester.pumpAndSettle();
      expect(left(tester, 'page'), 0);
    });

    testWidgets('fades the page in over a still page below', (tester) async {
      await pushHalfway(tester, TabAnimation.fade);

      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('page')),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(find.byType(CommonPageTransition), findsNothing);
      expect(fade.opacity.value, inExclusiveRange(0, 1));
      expect(left(tester, 'page'), 0);
      expect(left(tester, 'home'), 0);
    });
  });

  group('drag back', () {
    Future<void> openPage(
      WidgetTester tester,
      double width,
      Widget page,
    ) async {
      setViewWidth(width);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => BaseNavigator.push(context, page),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    const page = Scaffold(body: Center(child: Text('pushed page')));

    for (final width in [400.0, 1400.0]) {
      testWidgets('pops after a long right drag at width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await tester.timedDrag(
          find.text('pushed page'),
          Offset(tester.getSize(find.byType(Scaffold).last).width * 0.7, 0),
          const Duration(seconds: 1),
        );
        await tester.pumpAndSettle();

        expect(find.text('pushed page'), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });

      testWidgets('stays after a short slow right drag at width $width', (
        tester,
      ) async {
        await openPage(tester, width, page);

        await tester.timedDrag(
          find.text('pushed page'),
          const Offset(80, 0),
          const Duration(seconds: 1),
        );
        await tester.pumpAndSettle();

        expect(find.text('pushed page'), findsOneWidget);
        expect(tester.getTopLeft(find.byType(Scaffold).last), Offset.zero);
      });
    }

    testWidgets('pops on a quick right fling', (tester) async {
      await openPage(tester, 400, page);

      await tester.fling(find.text('pushed page'), const Offset(120, 0), 1500);
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsNothing);
    });

    testWidgets('is disabled when the page vetoes popping', (tester) async {
      await openPage(tester, 400, const PopScope(canPop: false, child: page));

      await tester.timedDrag(
        find.text('pushed page'),
        const Offset(300, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsOneWidget);
    });

    testWidgets('yields to a horizontal scrollable inside the page', (
      tester,
    ) async {
      await openPage(
        tester,
        400,
        Scaffold(
          body: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < 20; i++)
                SizedBox(width: 200, child: Text('item $i')),
            ],
          ),
        ),
      );
      final list = find.byType(Scrollable).last;
      tester.state<ScrollableState>(list).position.jumpTo(600);
      await tester.pump();

      await tester.timedDrag(
        list,
        const Offset(300, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('route configuration', () {
    test('desktop route exposes a transparent barrier and keeps state', () {
      final route = CommonDesktopRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
      expect(route.transitionDuration, const Duration(milliseconds: 200));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 200),
      );
    });

    test('mobile route uses the longer page duration', () {
      final route = CommonRoute<void>(builder: (_) => const SizedBox());

      expect(route.barrierColor, isNull);
      expect(route.barrierLabel, isNull);
      expect(route.maintainState, isTrue);
      expect(route.transitionDuration, const Duration(milliseconds: 300));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 300),
      );
    });
  });

  group('CommonPageTransition', () {
    Future<void> pumpTransitionHost(
      WidgetTester tester, {
      required PageTransitionsBuilder builder,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {TargetPlatform.android: builder},
            ),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('second')),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('drives the slide and shadow transitions on push', (
      tester,
    ) async {
      await pumpTransitionHost(
        tester,
        builder: const CommonPageTransitionsBuilder(),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byType(CommonPageTransition), findsWidgets);
      expect(find.byType(DecoratedBoxTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(tester.takeException(), null);
    });

    testWidgets('reverses cleanly and disposes its curves', (tester) async {
      await pumpTransitionHost(
        tester,
        builder: const CommonPageTransitionsBuilder(),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('second'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      expect(find.text('second'), findsNothing);
      expect(tester.takeException(), null);
    });

    testWidgets('rebuilds its animations when the inputs change', (
      tester,
    ) async {
      final first = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 200),
      );
      final second = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 200),
      );
      final secondary = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 200),
      );
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(secondary.dispose);

      Widget build(Animation<double> primary, {required bool linear}) {
        return MaterialApp(
          home: Builder(
            builder: (context) => CommonPageTransition(
              context: context,
              primaryRouteAnimation: primary,
              secondaryRouteAnimation: secondary,
              linearTransition: linear,
              child: const Text('content'),
            ),
          ),
        );
      }

      await tester.pumpWidget(build(first, linear: false));
      expect(find.text('content'), findsOneWidget);

      await tester.pumpWidget(build(second, linear: false));
      await tester.pump();
      expect(find.text('content'), findsOneWidget);

      await tester.pumpWidget(build(second, linear: true));
      await tester.pump();
      expect(find.text('content'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), null);
    });

    testWidgets('delegatedTransition slides the outgoing route', (
      tester,
    ) async {
      final secondary = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 200),
      );
      addTearDown(secondary.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) =>
                CommonPageTransition.delegatedTransition(
                  context,
                  const AlwaysStoppedAnimation<double>(0),
                  secondary,
                  false,
                  const Text('outgoing'),
                ) ??
                const SizedBox(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('outgoing'), findsOneWidget);
      expect(find.byType(SlideTransition), findsWidgets);

      secondary.value = 0.5;
      await tester.pump();
      expect(tester.takeException(), null);
    });
  });
}
