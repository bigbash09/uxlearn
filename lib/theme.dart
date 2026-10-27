import 'package:flutter/material.dart';

/// Brand colours from the UX Terms case study, defined for light and dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.blue,
    required this.blueInk,
    required this.peri,
    required this.tint,
    required this.tint2,
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.good,
    required this.amber,
    required this.bad,
    required this.night,
  });

  final Color blue,
      blueInk,
      peri,
      tint,
      tint2,
      bg,
      surface,
      ink,
      muted,
      line,
      good,
      amber,
      bad,
      night;
  Color get onBlue => Colors.white;

  static const light = AppColors(
    blue: Color(0xFF2A68E8),
    blueInk: Color(0xFF1D4FBF),
    peri: Color(0xFF8DB3FB),
    tint: Color(0xFFE9F0FE),
    tint2: Color(0xFFD6E4FD),
    bg: Color(0xFFF2F5FB),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF0F1A31),
    muted: Color(0xFF5A6580),
    line: Color(0xFFDEE5F2),
    good: Color(0xFF1E9E6A),
    amber: Color(0xFFF2B33D),
    bad: Color(0xFFD9483B),
    night: Color(0xFF101B3D),
  );

  static const dark = AppColors(
    blue: Color(0xFF4B83F2),
    blueInk: Color(0xFF8DB3FB),
    peri: Color(0xFF3A63B8),
    tint: Color(0xFF17284A),
    tint2: Color(0xFF1F3561),
    bg: Color(0xFF0B1120),
    surface: Color(0xFF141C2F),
    ink: Color(0xFFE7EDF9),
    muted: Color(0xFF97A3BE),
    line: Color(0xFF243150),
    good: Color(0xFF3CC48C),
    amber: Color(0xFFD9A23A),
    bad: Color(0xFFE5645A),
    night: Color(0xFF060B1C),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      blue: l(blue, other.blue),
      blueInk: l(blueInk, other.blueInk),
      peri: l(peri, other.peri),
      tint: l(tint, other.tint),
      tint2: l(tint2, other.tint2),
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      good: l(good, other.good),
      amber: l(amber, other.amber),
      bad: l(bad, other.bad),
      night: l(night, other.night),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

const kDisplay = 'Archivo';
const kBody = 'Figtree';

/// Display (expanded grotesk) style, used sparingly for titles.
TextStyle display(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w800,
  double height = 1.1,
}) => TextStyle(
  fontFamily: kDisplay,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: -0.2,
);

TextStyle body(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w400,
  double height = 1.45,
}) => TextStyle(
  fontFamily: kBody,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

TextStyle eyebrow(Color color) => TextStyle(
  fontFamily: kBody,
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.9,
  color: color,
);

ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.light ? AppColors.light : AppColors.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: kBody,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.blue,
      brightness: b,
      primary: c.blue,
      surface: c.surface,
    ),
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
  );
  return base.copyWith(
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.blue),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      showDragHandle: true,
      dragHandleColor: c.line,
    ),
    dialogTheme: DialogThemeData(backgroundColor: c.surface),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: body(14, c.bg, weight: FontWeight.w600),
      shape: const StadiumBorder(),
    ),
  );
}
