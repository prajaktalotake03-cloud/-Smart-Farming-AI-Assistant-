import 'dart:developer';
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;
  
  // Default emulator IP (10.0.2.2 maps to localhost of host machine in Android)
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000';
  
  String _baseUrl = _defaultBaseUrl;
  
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging Interceptor for Debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('🌐 API Request: [${options.method}] ${options.uri}');
          if (options.data != null) log('📦 Request Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('✅ API Response: [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('❌ API Error: [${e.response?.statusCode}] ${e.message}');
          log('❌ API Error details: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  // Allow dynamic base URL updates (e.g. from developer options / settings screen)
  void setBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  String get baseUrl => _baseUrl;

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException {
      rethrow;
    }
  }

  // Helper method to check if the backend is reachable
  Future<bool> isBackendOnline() async {
    try {
      final response = await _dio.get('/health', options: Options(receiveTimeout: const Duration(seconds: 2)));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
