import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'submit_grievance_screen.dart';
import 'grievance_details_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class AppRouter {
  static final _auth = FirebaseAuth.instance;

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/submit',
        builder: (context, state) => const SubmitGrievanceScreen(),
      ),
      GoRoute(
        path: '/details/:id',
        builder: (context, state) =>
            GrievanceDetailsScreen(grievanceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final user = _auth.currentUser;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      developer.log(
        'Router Redirect: user=${user?.email}, location=${state.matchedLocation}',
        name: 'com.example.myapp.router',
      );

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((event) {
      developer.log('Auth state changed: $event', name: 'com.example.myapp.auth');
      notifyListeners();
    });
  }
}
