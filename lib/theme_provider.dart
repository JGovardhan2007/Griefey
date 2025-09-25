import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Manages the application's theme state (light, dark, or system).
class AppThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Toggles between light and dark theme, ignoring system theme.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

/// Defines the application's color palette and text styles.
class AppThemes {
  // Private constants for colors to ensure a consistent palette.
  static const Color _lightSeedColor = Color(0xFF1E88E5); // A vibrant blue
  static const Color _darkSeedColor = Color(0xFF673AB7);  // A deep purple

  // Centralized TextTheme using Google Fonts for consistency.
  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
    headlineLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0.25),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
  );

  /// The light theme configuration for the app.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightSeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  /// The dark theme configuration for the app.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkSeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  // Shared component themes to reduce duplication.
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    clipBehavior: Clip.antiAlias, // Ensures content respects the rounded corners
  );

  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
  );
}
