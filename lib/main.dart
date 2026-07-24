import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
import 'features/crop_health/presentation/providers/crop_health_provider.dart';
import 'features/soil_yield/presentation/providers/soil_yield_provider.dart';
import 'features/ai_assistant/presentation/providers/chat_provider.dart';
import 'features/irrigation/presentation/providers/irrigation_provider.dart';
import 'features/fertilizer/presentation/providers/fertilizer_provider.dart';
import 'features/market/presentation/providers/market_provider.dart';
import 'features/schemes/presentation/providers/schemes_provider.dart';
import 'core/theme/theme_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (wrapped in a try-catch to enable mock mode if configs are missing)
  try {
    await Firebase.initializeApp();
    debugPrint('🔥 Firebase initialized successfully.');
  } catch (e) {
    debugPrint('⚠️ Firebase configuration not found or initialization failed. Falling back to Mock Auth: $e');
  }

  // Create Singletons
  final apiClient = ApiClient();
  final authRepository = AuthRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CropHealthProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SoilYieldProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => IrrigationProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => FertilizerProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SchemesProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Smart Farming AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
