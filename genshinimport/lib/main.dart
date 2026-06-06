import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pages/auth_page.dart';
import 'pages/weapon_list.dart';
import 'pages/user_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;
  String? _role;
  int? _userId;

  void _handleLogin(String token, String role, int userId) {
    setState(() {
      _token = token;
      _role = role;
      _userId = userId;
    });
  }

  void _logout() {
    setState(() {
      _token = null;
      _role = null;
      _userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Import',
      theme: AppTheme.light(),
      home: _token == null
          ? AuthPage(onLoginSuccess: _handleLogin)
          : _role == 'admin'
          ? WeaponListPage(token: _token!, onLogout: _logout)
          : UserDashboardPage(
              token: _token!,
              userId: _userId!,
              onLogout: _logout,
            ),
    );
  }
}
