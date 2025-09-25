import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/signup_screen.dart';
import 'package:myapp/submit_grievance_screen.dart';
import 'package:myapp/admin_screen.dart';
import 'package:myapp/grievance_details_screen.dart';
import 'package:myapp/profile_screen.dart';
import 'package:myapp/edit_grievance_screen.dart';
import 'package:myapp/edit_profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: 'submit',
            builder: (context, state) => const SubmitGrievanceScreen(),
          ),
          GoRoute(
            path: 'admin',
            builder: (context, state) => const AdminScreen(),
          ),
          GoRoute(
            path: 'details/:grievanceId',
            builder: (context, state) {
              final grievanceId = state.pathParameters['grievanceId']!;
              return GrievanceDetailsScreen(grievanceId: grievanceId);
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'edit_grievance/:grievanceId',
            builder: (context, state) {
              final grievanceId = state.pathParameters['grievanceId']!;
              return EditGrievanceScreen(grievanceId: grievanceId);
            },
          ),
          GoRoute(
            path: 'edit_profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
