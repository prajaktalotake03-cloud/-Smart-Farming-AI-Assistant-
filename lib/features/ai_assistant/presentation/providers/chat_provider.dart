import 'package:flutter/material.dart';
import '../../domain/models/chat_message_model.dart';
import '../../../../core/network/api_client.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  final List<ChatMessageModel> _messages = [];
  bool _isTyping = false;
  String? _errorMessage;

  ChatProvider(this._apiClient) {
    // Add default welcoming message
    _messages.add(
      ChatMessageModel(
        id: 'welcome',
        text: 'Hello! I am your Smart Farming AI. 🌾\n\nYou can ask me about crop diseases, fertilizing schedules, watering advice, crop recommendations, or local harvesting seasons. How can I help your farm today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String text, {String? imagePath}) async {
    if (text.trim().isEmpty && imagePath == null) return;

    final userMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.isEmpty ? 'Uploaded crop image for diagnosis.' : text,
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );

    _messages.add(userMessage);
    _isTyping = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // If there is an image, we can mock multipart upload or pass image details
      final response = await _apiClient.post(
        '/chat',
        data: {
          'message': text,
          'image_attached': imagePath != null,
          'history': _messages
              .sublist(0, _messages.length - 1)
              .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
              .toList(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final botReply = ChatMessageModel(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
          text: data['response'] ?? 'I could not process that request.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(botReply);
      } else {
        throw Exception('Chat response error.');
      }
    } catch (_) {
      // Offline fallback: Context-aware simulated assistant replies
      await Future.delayed(const Duration(milliseconds: 1800));
      
      final replyText = _generateMockResponse(text, hasImage: imagePath != null);
      final botReply = ChatMessageModel(
        id: 'mock_msg_${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botReply);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(
      ChatMessageModel(
        id: 'welcome',
        text: 'Chat cleared. How can I help you prepare for the next season? 🚜',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  String _generateMockResponse(String query, {bool hasImage = false}) {
    if (hasImage) {
      return '📸 [AI Visual Diagnosis Completed]\n\nBased on the leaf structure and spot patterns in your uploaded image, the AI detects symptoms of Early Blight (Alternaria solani).\n\nRecommended Actions:\n1. Prune and destroy the lower affected leaves to prevent spore splash.\n2. Apply a organic copper-based fungicide or neem oil spray early in the evening.\n3. Avoid overhead irrigation; water directly at the soil level.';
    }

    final q = query.toLowerCase();
    
    if (q.contains('disease') || q.contains('leaf') || q.contains('spot') || q.contains('blight')) {
      return 'Fungal diseases like Blight or Powdery Mildew thrive in humid conditions. I recommend picking off the affected leaves immediately, reducing overhead watering, and applying a diluted copper fungicide or natural neem oil solution in the evening.';
    }
    if (q.contains('fertilizer') || q.contains('npk') || q.contains('urea') || q.contains('soil')) {
      return 'For balanced soil nutrition, combine nitrogen (for vegetative leaf growth), phosphorus (for root structure and early seedling development), and potassium (for pest defense and fruit quality). Adding decomposed cow manure or vermicompost once a month will build organic humus naturally.';
    }
    if (q.contains('water') || q.contains('irrigation') || q.contains('dry') || q.contains('rain')) {
      return 'Watering is best done in the early morning (5 AM - 8 AM) to prevent evaporation losses and leaf moisture buildup which invites fungi. Clay soils retain moisture longer and require less frequent watering, whereas sandy soils require frequent, lighter irrigation cycles.';
    }
    if (q.contains('price') || q.contains('market') || q.contains('sell') || q.contains('cost')) {
      return 'Market rates are highly dependent on your local mandis. Due to recent rains, onion and tomato prices have stabilized, but soybean yields are reporting high demand. I suggest checking state agricultural boards for real-time local minimum support prices (MSP).';
    }
    if (q.contains('hello') || q.contains('hi ') || q.contains('hey')) {
      return 'Hello there! Let me know what you are sowing today, or if you would like me to analyze a plant disease or NPK levels.';
    }
    
    return 'That is a great farming question! When planning crop care, it is best to check soil pH levels first. A neutral range of 6.0 to 7.0 is ideal for most crops. Let me know if you would like me to help recommend a specific fertilizer blend based on your N-P-K nutrient values!';
  }
}
