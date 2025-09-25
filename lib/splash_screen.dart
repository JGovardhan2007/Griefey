import 'package:flutter/material.dart';

/// A simple, stateless splash screen.
///
/// This screen is displayed briefly while the application determines the
/// initial route based on the user's authentication status. It does not
/// contain any navigation logic itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // It is recommended to use a more modern and adaptive logo if possible.
            // For now, we will keep the existing one.
            Image(
              image: AssetImage('assets/images/griefey_logo.png'),
              height: 150,
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
