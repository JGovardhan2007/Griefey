
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/theme_provider.dart';

void main() {
  group('AppThemeProvider', () {
    test('initial themeMode is ThemeMode.system', () {
      final themeProvider = AppThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates the themeMode and notifies listeners', () {
      final themeProvider = AppThemeProvider();
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(notified, isTrue);

      notified = false;
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(notified, isTrue);
      
      notified = false;
      themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(notified, isTrue);
    });
  });
}
