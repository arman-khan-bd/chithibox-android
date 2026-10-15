import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chithi_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  await apiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService: apiService)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChithiProvider(apiService: apiService),
        ),
      ],
      child: const ChithiApp(),
    ),
  );
}

class ChithiApp extends StatelessWidget {
  const ChithiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'চিঠিবক্স (ChithiBox)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading && auth.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
