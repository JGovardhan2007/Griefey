import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'app_router.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions? firebaseOptions;
  if (kIsWeb) {
    firebaseOptions = FirebaseOptions(
      apiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
      authDomain: "localhost",
      projectId: DefaultFirebaseOptions.currentPlatform.projectId,
      storageBucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
      messagingSenderId: DefaultFirebaseOptions.currentPlatform.messagingSenderId,
      appId: DefaultFirebaseOptions.currentPlatform.appId,
      measurementId: DefaultFirebaseOptions.currentPlatform.measurementId,
    );
  }

  await Firebase.initializeApp(
    options: firebaseOptions ?? DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AuthWrapper());
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While Firebase is figuring out the auth state, show a loading screen.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Once the auth state is known, build the main app.
        return ChangeNotifierProvider(
          create: (context) => AppThemeProvider(),
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Griefey',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
