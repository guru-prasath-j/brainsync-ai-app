import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

Future<bool> _isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  return token != null && token.isNotEmpty;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) async {
    final loggedIn = await _isLoggedIn();
    final onAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash';

    if (!loggedIn && !onAuth) return '/login';
    if (loggedIn && (state.matchedLocation == '/login' ||
        state.matchedLocation == '/register')) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
