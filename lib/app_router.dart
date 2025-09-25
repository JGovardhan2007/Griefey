import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_service.dart';
import 'admin_screen.dart';
import 'grievance_details_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
import 'submit_grievance_screen.dart';
import 'edit_profile_screen.dart';

class AppRouter {
  final AuthService authService;

  AppRouter({required this.authService});

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/login',
    routes: _routes,
    redirect: _redirect,
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
  );

  // Private list of all routes
  static final List<RouteBase> _routes = <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home', // Redirect root to home
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
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GrievanceDetailsScreen(grievanceId: id);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
     GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ];

  // Redirect logic based on authentication status
  FutureOr<String?> _redirect(BuildContext context, GoRouterState state) {
    final bool loggedIn = authService.currentUser != null;
    final String location = state.matchedLocation;

    developer.log(
      'Router Redirect: loggedIn=$loggedIn, location=$location',
      name: 'com.example.griefey.router',
    );

    // Check if the user is on a public page (login or signup)
    final bool isPublicPage = location == '/login' || location == '/signup';

    if (!loggedIn) {
      // If the user is not logged in, they can only access public pages.
      // Otherwise, redirect them to the login page.
      return isPublicPage ? null : '/login';
    }

    // If the user is logged in but trying to access a public page, redirect to home.
    if (isPublicPage) {
      return '/home';
    }

    // No redirection needed.
    return null;
  }
}

// Helper class to notify GoRouter of auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
