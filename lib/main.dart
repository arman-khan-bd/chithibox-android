import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chithi_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

// Enables seamless HTTPS connections on legacy devices (e.g. Android 6.0.1 Marshmallow)
// where expired Let's Encrypt / DST Root CA X3 would otherwise throw CERTIFICATE_VERIFY_FAILED
class ChithiHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host == 'gb.e-bd.shop' || host.endsWith('.e-bd.shop')) {
          return true;
        }
        return false;
      };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = ChithiHttpOverrides();

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
