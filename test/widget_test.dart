import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:chithi_app/main.dart';
import 'package:chithi_app/services/api_service.dart';
import 'package:chithi_app/providers/auth_provider.dart';
import 'package:chithi_app/providers/chithi_provider.dart';

void main() {
  testWidgets('ChithiApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final apiService = ApiService();
    await apiService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(apiService: apiService)),
          ChangeNotifierProvider(create: (_) => ChithiProvider(apiService: apiService)),
        ],
        child: const ChithiApp(),
      ),
    );

    expect(find.byType(ChithiApp), findsOneWidget);
  });
}
