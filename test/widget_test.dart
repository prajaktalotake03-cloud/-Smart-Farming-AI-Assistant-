import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming_ai_assistant/main.dart';
import 'package:smart_farming_ai_assistant/core/network/api_client.dart';
import 'package:smart_farming_ai_assistant/core/theme/theme_provider.dart';
import 'package:smart_farming_ai_assistant/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_farming_ai_assistant/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_farming_ai_assistant/features/weather/presentation/providers/weather_provider.dart';
import 'package:smart_farming_ai_assistant/features/crop_health/presentation/providers/crop_health_provider.dart';
import 'package:smart_farming_ai_assistant/features/soil_yield/presentation/providers/soil_yield_provider.dart';
import 'package:smart_farming_ai_assistant/features/ai_assistant/presentation/providers/chat_provider.dart';
import 'package:smart_farming_ai_assistant/features/irrigation/presentation/providers/irrigation_provider.dart';
import 'package:smart_farming_ai_assistant/features/fertilizer/presentation/providers/fertilizer_provider.dart';
import 'package:smart_farming_ai_assistant/features/market/presentation/providers/market_provider.dart';
import 'package:smart_farming_ai_assistant/features/schemes/presentation/providers/schemes_provider.dart';
import 'package:smart_farming_ai_assistant/features/profile/presentation/providers/profile_provider.dart';

void main() {
  testWidgets('App starts and shows Splash Screen smoke test', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final authRepository = AuthRepositoryImpl();

    // Wrap MyApp inside the MultiProvider containing all required ChangeNotifiers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
          ChangeNotifierProvider(create: (_) => WeatherProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => CropHealthProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => SoilYieldProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => ChatProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => IrrigationProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => FertilizerProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => MarketProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => SchemesProvider(apiClient)),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen shows key text
    expect(find.text('Smart Farming AI'), findsOneWidget);

    // Pump frames to complete the 3-second navigation timer and settle transitions
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
