import 'package:flutter/material.dart';

/// LocaLink Design System Tokens & Themes
/// Derived directly from the LocaLink UI and UX specification (v2).
/// Colors: Teal = Services, Indigo = Places, Amber = Shops, Red = SOS only.
class AppColors {
  // Brand Module Colors
  static const Color teal = Color(0xFF0E5E63); // Services, primary
  static const Color tealDark = Color(0xFF07383B);
  static const Color tealLight = Color(0xFFE2F0EF);

  static const Color indigo = Color(0xFF3D4F9F); // Places
  static const Color indigoDark = Color(0xFF243068);
  static const Color indigoLight = Color(0xFFE8EBF8);

  static const Color amber = Color(0xFFB97800); // Shops
  static const Color amberDark = Color(0xFF7A4F00);
  static const Color amberLight = Color(0xFFFBF2DC);

  static const Color red = Color(0xFFC0392B); // SOS only
  static const Color redLight = Color(0xFFE5493A);
  static const Color redDark = Color(0xFFB02A1E);

  // Status & Accents
  static const Color star = Color(0xFFE8A317);
  static const Color myLocation = Color(0xFF2F6FED);
  static const Color success = Color(0xFF1B8755);

  // Light Mode Neutrals
  static const Color bgLight = Color(0xFFEEF3F2);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF0F1F23);
  static const Color muteLight = Color(0xFF5B6D70);
  static const Color secondaryMuteLight = Color(0xFF66777A);
  static const Color lineLight = Color(0xFFD6E0DF);
  static const Color inputBorderLight = Color(0xFFDDE6E5);

  // Dark Mode Neutrals
  static const Color bgDark = Color(0xFF0B1416);
  static const Color cardDark = Color(0xFF14262A);
  static const Color inkDark = Color(0xFFE7F0EF);
  static const Color muteDark = Color(0xFF9FB2B4);
  static const Color lineDark = Color(0xFF223437);
  static const Color inputBorderDark = Color(0xFF2E4347);
}

/// Helper design styles & decorations
class AppDecorations {
  static const String fontFamily = 'Plus Jakarta Sans';
  static const List<String> fontFamilyFallbacks = [
    'Plus Jakarta Sans',
    'system-ui',
    '-apple-system',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static const double cardRadius = 14.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 99.0;
  static const double inputRadius = 11.0;
  static const double minTouchTarget = 48.0;

  static BoxDecoration cardBox({
    Color color = AppColors.cardLight,
    Border? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? BorderRadius.circular(cardRadius),
      border: border ?? Border.all(color: AppColors.lineLight),
      boxShadow: boxShadow ??
          const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
    );
  }

  static BoxDecoration primaryGradient({
    Color startColor = AppColors.teal,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          startColor,
          Color.lerp(startColor, Colors.black, 0.35) ?? startColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(buttonRadius),
      boxShadow: [
        BoxShadow(
          color: startColor.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static BoxDecoration sosGradient({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.redLight, AppColors.redDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55C0392B),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    );
  }
}

/// Builds the Light Theme conforming to the LocaLink UI/UX Spec
ThemeData buildAppTheme() {
  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.02,
      color: AppColors.inkLight,
    ),
    displayMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.02,
      color: AppColors.inkLight,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.01,
      color: AppColors.inkLight,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: AppColors.inkLight,
    ),
    titleLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.inkLight,
    ),
    titleMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.inkLight,
    ),
    titleSmall: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.muteLight,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.inkLight,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.muteLight,
    ),
    bodySmall: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryMuteLight,
    ),
    labelLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.inkLight,
    ),
    labelMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.muteLight,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppDecorations.fontFamily,
    fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.indigo,
      onSecondary: Colors.white,
      tertiary: AppColors.amber,
      onTertiary: Colors.white,
      error: AppColors.red,
      onError: Colors.white,
      surface: AppColors.cardLight,
      onSurface: AppColors.inkLight,
      outline: AppColors.lineLight,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgLight,
      foregroundColor: AppColors.inkLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppDecorations.fontFamily,
        fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.inkLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        side: const BorderSide(color: AppColors.lineLight),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(AppDecorations.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppDecorations.fontFamily,
          fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal,
        minimumSize: const Size.fromHeight(AppDecorations.minTouchTarget),
        side: const BorderSide(color: AppColors.teal, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppDecorations.fontFamily,
          fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(
        color: AppColors.secondaryMuteLight,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.inputBorderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.inputBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.red),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.teal.withValues(alpha: 0.15),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.muteLight,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.teal, size: 22);
        }
        return const IconThemeData(color: AppColors.muteLight, size: 22);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDecorations.chipRadius),
        side: const BorderSide(color: AppColors.inputBorderLight),
      ),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.inkLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lineLight,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Builds the Dark Theme conforming to the LocaLink UI/UX Spec
ThemeData buildDarkTheme() {
  const darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.02,
      color: AppColors.inkDark,
    ),
    displayMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.02,
      color: AppColors.inkDark,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: AppColors.inkDark,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: AppColors.inkDark,
    ),
    titleLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.inkDark,
    ),
    titleMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.inkDark,
    ),
    titleSmall: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.muteDark,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.inkDark,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.muteDark,
    ),
    bodySmall: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.muteDark,
    ),
    labelLarge: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.inkDark,
    ),
    labelMedium: TextStyle(
      fontFamily: AppDecorations.fontFamily,
      fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.muteDark,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppDecorations.fontFamily,
    fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.indigo,
      onSecondary: Colors.white,
      tertiary: AppColors.amber,
      onTertiary: Colors.white,
      error: AppColors.red,
      onError: Colors.white,
      surface: AppColors.cardDark,
      onSurface: AppColors.inkDark,
      outline: AppColors.lineDark,
    ),
    textTheme: darkTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.inkDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppDecorations.fontFamily,
        fontFamilyFallback: AppDecorations.fontFamilyFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.inkDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        side: const BorderSide(color: AppColors.lineDark),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(
        color: AppColors.muteDark,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.inputBorderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.inputBorderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      indicatorColor: AppColors.teal.withValues(alpha: 0.25),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.muteDark,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.teal, size: 22);
        }
        return const IconThemeData(color: AppColors.muteDark, size: 22);
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lineDark,
      thickness: 1,
      space: 1,
    ),
  );
}
