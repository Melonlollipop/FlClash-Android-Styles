import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class InterfaceStyleTheme extends ThemeExtension<InterfaceStyleTheme> {
  const InterfaceStyleTheme({
    this.style = InterfaceStyle.material,
    this.barBlur = false,
    this.liquidGlass = false,
    this.predictiveBack = false,
  });

  final InterfaceStyle style;
  final bool barBlur;
  final bool liquidGlass;
  final bool predictiveBack;

  bool get isMiuix => style == InterfaceStyle.miuix;

  @override
  InterfaceStyleTheme copyWith({
    InterfaceStyle? style,
    bool? barBlur,
    bool? liquidGlass,
    bool? predictiveBack,
  }) {
    return InterfaceStyleTheme(
      style: style ?? this.style,
      barBlur: barBlur ?? this.barBlur,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      predictiveBack: predictiveBack ?? this.predictiveBack,
    );
  }

  @override
  InterfaceStyleTheme lerp(InterfaceStyleTheme? other, double t) {
    if (other == null || t < 0.5) {
      return this;
    }
    return other;
  }

  @override
  bool operator ==(Object other) {
    return other is InterfaceStyleTheme &&
        other.style == style &&
        other.barBlur == barBlur &&
        other.liquidGlass == liquidGlass &&
        other.predictiveBack == predictiveBack;
  }

  @override
  int get hashCode => Object.hash(style, barBlur, liquidGlass, predictiveBack);
}

extension InterfaceStyleContext on BuildContext {
  InterfaceStyleTheme get interfaceStyle =>
      Theme.of(this).extension<InterfaceStyleTheme>() ??
      const InterfaceStyleTheme();
}

extension InterfaceStyleThemeData on ThemeData {
  ThemeData withInterfaceStyle(InterfaceStyleTheme interfaceStyle) {
    return copyWith(
      extensions: [
        for (final extension in extensions.values)
          if (extension is! InterfaceStyleTheme) extension,
        interfaceStyle,
      ],
    );
  }
}

/// The stock Miuix palette (compose-miuix `lightColorScheme`/`darkColorScheme`)
/// mapped onto Material roles: pages on `surface`, cards on `surfaceContainer`.
ColorScheme miuixColorScheme(Brightness brightness) {
  return switch (brightness) {
    Brightness.light => _miuixLight,
    Brightness.dark => _miuixDark,
  };
}

const _miuixLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF3482FF),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF5D9BFF),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFF3482FF),
  primaryFixedDim: Color(0xFF5D9BFF),
  onPrimaryFixed: Color(0xFFFFFFFF),
  onPrimaryFixedVariant: Color(0xFFAECDFF),
  secondary: Color(0xFFE6E6E6),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF0F0F0),
  onSecondaryContainer: Color(0xFF303030),
  secondaryFixed: Color(0xFFE6E6E6),
  secondaryFixedDim: Color(0xFFF0F0F0),
  onSecondaryFixed: Color(0xFF303030),
  onSecondaryFixedVariant: Color(0xFFA8A8A8),
  tertiary: Color(0xFF3482FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEAF2FF),
  onTertiaryContainer: Color(0xFF3482FF),
  tertiaryFixed: Color(0xFFEAF2FF),
  tertiaryFixedDim: Color(0xFFEAF2FF),
  onTertiaryFixed: Color(0xFF3482FF),
  onTertiaryFixedVariant: Color(0xFF3482FF),
  error: Color(0xFFE94634),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFDF6F4),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFF7F7F7),
  onSurface: Color(0xFF000000),
  surfaceDim: Color(0xFFF7F7F7),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFFFFFFF),
  surfaceContainerHigh: Color(0xFFE8E8E8),
  surfaceContainerHighest: Color(0xFFE8E8E8),
  onSurfaceVariant: Color(0x99000000),
  outline: Color(0xFFD9D9D9),
  outlineVariant: Color(0xFFE0E0E0),
  shadow: Color(0xFF000000),
  scrim: Color(0x4D000000),
  inverseSurface: Color(0xFF242424),
  onInverseSurface: Color(0xFFF2F2F2),
  inversePrimary: Color(0xFF277AF7),
  surfaceTint: Color(0x00000000),
);

const _miuixDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF277AF7),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF338FE4),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFF277AF7),
  primaryFixedDim: Color(0xFF338FE4),
  onPrimaryFixed: Color(0xFFFFFFFF),
  onPrimaryFixedVariant: Color(0xFF99C7F1),
  secondary: Color(0xFF505050),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF434343),
  onSecondaryContainer: Color(0xFFD9D9D9),
  secondaryFixed: Color(0xFF505050),
  secondaryFixedDim: Color(0xFF434343),
  onSecondaryFixed: Color(0xFFD9D9D9),
  onSecondaryFixedVariant: Color(0xFF959595),
  tertiary: Color(0xFF4788FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF2B3B54),
  onTertiaryContainer: Color(0xFF4788FF),
  tertiaryFixed: Color(0xFF2B3B54),
  tertiaryFixedDim: Color(0xFF2B3B54),
  onTertiaryFixed: Color(0xFF4788FF),
  onTertiaryFixedVariant: Color(0xFF4788FF),
  error: Color(0xFFF12522),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF2E0603),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF000000),
  onSurface: Color(0xFFF2F2F2),
  surfaceDim: Color(0xFF000000),
  surfaceBright: Color(0xFF2D2D2D),
  surfaceContainerLowest: Color(0xFF000000),
  surfaceContainerLow: Color(0xFF242424),
  surfaceContainer: Color(0xFF242424),
  surfaceContainerHigh: Color(0xFF242424),
  surfaceContainerHighest: Color(0xFF2D2D2D),
  onSurfaceVariant: Color(0x80FFFFFF),
  outline: Color(0xFF404040),
  outlineVariant: Color(0xFF393939),
  shadow: Color(0xFF000000),
  scrim: Color(0x99000000),
  inverseSurface: Color(0xFFF7F7F7),
  onInverseSurface: Color(0xFF000000),
  inversePrimary: Color(0xFF3482FF),
  surfaceTint: Color(0x00000000),
);
