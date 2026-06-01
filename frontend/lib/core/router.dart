import 'package:flutter/material.dart';
import 'package:brainsync/screens/splash_screen.dart';
import 'package:brainsync/screens/login_screen.dart';
import 'package:brainsync/screens/register_screen.dart';
import 'package:brainsync/screens/home_screen.dart';
import 'package:brainsync/screens/profile_screen.dart';
import 'package:brainsync/screens/upload_screen.dart';
import 'package:brainsync/screens/notes_list_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String upload = '/upload';
  static const String notes = '/notes';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case upload:
        return MaterialPageRoute(builder: (_) => const UploadScreen());
      case notes:
        return MaterialPageRoute(builder: (_) => const NotesListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ' + (settings.name ?? 'unknown'))),
          ),
        );
    }
  }
}