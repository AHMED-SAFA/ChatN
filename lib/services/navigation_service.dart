import 'package:chat/pages/gemini_page.dart';
import 'package:chat/pages/home_page.dart';
import 'package:chat/pages/login_page.dart';
import 'package:chat/pages/openapi_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/register_page.dart';
import 'package:flutter/material.dart';
import '../pages/notification_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const Login(),
    "/home": (context) => const Home(),
    "/register": (context) => const RegisterPage(),
    "/profile": (context) => const ProfilePage(),
    "/notification": (context) => const NotificationPage(),
    "/gemini": (context) => const GeminiPage(),
    "/gpt": (context) => const OpenapiPage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }
  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }
}
