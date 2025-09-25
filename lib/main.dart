import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'app_router.dart';
import 'theme_provider.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up providers
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, themeProvider, child) {
          final authService = Provider.of<AuthService>(context, listen: false);
          
          return MaterialApp.router(
            title: 'Griefey',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter(authService: authService).router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
