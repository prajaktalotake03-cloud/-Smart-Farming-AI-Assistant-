class AppConstants {
  // App Identity
  static const String appName = 'Smart Farming AI';
  static const String appVersion = '1.0.0';

  // API Endpoints (FastAPI)
  static const String endpointHealth = '/health';
  static const String endpointDiagnose = '/diagnose';
  static const String endpointRecommendCrop = '/recommend_crop';
  static const String endpointPredictYield = '/predict_yield';
  static const String endpointChat = '/chat';

  // Local Storage Shared Preference Keys
  static const String keyThemeMode = 'prefs_theme_mode';
  static const String keyUserToken = 'prefs_user_token';
  static const String keyUserProfile = 'prefs_user_profile';
  static const String keyOfflineMode = 'prefs_offline_mode';
  
  // Custom Farming Advisories (Fallback default list)
  static const List<String> quickCropTips = [
    'Ensure proper nitrogen levels for leafy green crops like spinach.',
    'Water tomato plants at the root zone rather than overhead to prevent leaf spot.',
    'Test soil pH every 2-3 years to verify nutrient availability.',
    'Introduce cover crops like clover during winter to naturally fertilize the soil.',
  ];
}
