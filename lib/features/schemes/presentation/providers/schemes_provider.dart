import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class SchemeItem {
  final String title;
  final String category;
  final String description;
  final String benefits;
  final String eligibility;
  final String emoji;
  bool isApplied;

  SchemeItem({
    required this.title,
    required this.category,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.emoji,
    this.isApplied = false,
  });
}

class SchemesProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<SchemeItem> _schemes = [];

  SchemesProvider(this._apiClient) {
    fetchSchemes();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SchemeItem> get schemes => List.unmodifiable(_schemes);

  Future<void> fetchSchemes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/schemes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['schemes'] ?? [];
        
        _schemes = data.map((item) => SchemeItem(
          title: item['title'] ?? 'Scheme',
          category: item['category'] ?? 'General',
          description: item['description'] ?? '',
          benefits: item['benefits'] ?? '',
          eligibility: item['eligibility'] ?? '',
          emoji: item['emoji'] ?? '🏛️',
          isApplied: item['applied'] as bool? ?? false,
        )).toList();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('API replied with code: ${response.statusCode}');
      }
    } catch (_) {
      // Fallback: Populate mock scheme list
      await Future.delayed(const Duration(milliseconds: 800));

      _schemes = [
        SchemeItem(
          title: 'PM-KISAN (Samman Nidhi)',
          category: 'Income Support',
          emoji: '💰',
          description: 'Direct cash transfer scheme to support farmer households for purchasing seeds, fertilizers, and equipment.',
          benefits: '₹6,000 per year, paid in three equal direct bank installments of ₹2,000 every four months.',
          eligibility: 'All small and marginal landholding farmer families who own cultivable land in their names.',
        ),
        SchemeItem(
          title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
          category: 'Crop Insurance',
          emoji: '🌾',
          description: 'A comprehensive crop insurance scheme safeguarding against yields failure due to natural calamities, pests, and local risks.',
          benefits: 'Low premium rate (1.5% to 2% for food crops, 5% for commercial crops) with complete insurance cover of sum insured.',
          eligibility: 'All farmers (including sharecroppers and tenant farmers) cultivating notified crops in notified areas.',
        ),
        SchemeItem(
          title: 'Soil Health Card Scheme',
          category: 'Soil Advisory',
          emoji: '🧪',
          description: 'A national scheme providing field-specific soil nutrient reports containing macro/micro nutrient levels and organic suggestions.',
          benefits: 'Free scientific lab analysis of soil sample. Receive customized fertilizer dosage advice card valid for 3 years.',
          eligibility: 'All farmers across Indian states having operational agriculture holdings.',
        ),
        SchemeItem(
          title: 'Tractor & Machinery Subsidies',
          category: 'Subsidies & Equipment',
          emoji: '🚜',
          description: 'Financial aid scheme to encourage farm mechanization, offering rebates on tractors, power tillers, and drip systems.',
          benefits: 'Subsidy rebates ranging from 40% to 50% on capital cost of machinery purchased through authorized mandis.',
          eligibility: 'Small/marginal farmers, women farmers, and registered self-help cooperatives owning agricultural lands.',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    }
  }

  void applyForScheme(String schemeTitle) {
    final idx = _schemes.indexWhere((s) => s.title == schemeTitle);
    if (idx != -1) {
      _schemes[idx].isApplied = true;
      notifyListeners();
    }
  }
}
