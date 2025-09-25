import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppThemes {
  static final Color _lightSeedColor = Colors.blue.shade800;
  static final Color _darkSeedColor = Colors.deepPurple.shade300;

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(
        fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
    headlineLarge: GoogleFonts.roboto(
        fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0.25),
    titleLarge:
        GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium:
        GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium:
        GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge:
        GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightSeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle:
          GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle:
            GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkSeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle:
          GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle:
            GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
    ),
  );
}
