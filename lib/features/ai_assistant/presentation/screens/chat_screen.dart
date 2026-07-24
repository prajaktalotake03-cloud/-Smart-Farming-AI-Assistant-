import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/chat_provider.dart';
import '../../domain/models/chat_message_model.dart';
import '../../../../core/theme/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  
  String? _selectedImagePath;
  bool _isListening = false;

  final List<String> _suggestions = [
    'How do I treat Tomato Early Blight?',
    'What NPK level is best for Wheat?',
    'Tips for watering rice crops',
    'How do I raise soil pH levels?'
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty && _selectedImagePath == null) return;
    
    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      text,
      imagePath: _selectedImagePath,
    );
    
    setState(() {
      _selectedImagePath = null;
    });
    
    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _startVoiceInput() {
    setState(() {
      _isListening = true;
    });

    // Simulate voice to text conversion after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      final voiceQueries = [
        'How do I handle powdery mildew on grapes?',
        'Best fertilizers for sandy loam soil',
        'When is the harvest season for Cotton?',
        'Drip irrigation frequency for tomatoes'
      ];
      
      final randomQuery = (voiceQueries..shuffle()).first;
      
      setState(() {
        _isListening = false;
        _textController.text = randomQuery;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice Captured: "$randomQuery"'),
          backgroundColor: AppTheme.emeraldGreen,
        ),
      );
    });
  }

  void _showImagePickerSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Crop Image',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.emeraldGreen),
                title: const Text('Take Photo from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.emeraldGreen),
                title: const Text('Select Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ChatProvider>(context);

    if (provider.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Farming AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            onPressed: () {
              provider.clearChat();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation cleared.')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages Scroll Panel
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageBubble(message, theme, isDark);
                  },
                ),
              ),

              // Bouncing Typing Dots Animation
              if (provider.isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, bottom: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            'AI is analyzing soil & crop details',
                            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          _buildBouncingDots(),
                        ],
                      ),
                    ),
                  ),
                ),

              // Suggested Questions Chips
              if (!provider.isTyping && _selectedImagePath == null)
                FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                          child: ActionChip(
                            label: Text(
                              _suggestions[index],
                              style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                            ),
                            backgroundColor: isDark ? const Color(0xFF13251A) : const Color(0xFFE8F5E9),
                            side: BorderSide(color: AppTheme.emeraldGreen.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: () => _send(_suggestions[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Selected Image Preview Panel above input tray
              if (_selectedImagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF13251A) : const Color(0xFFE8F5E9),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedImagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Photo attached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(
                                  _selectedImagePath!.split('/').last,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _selectedImagePath = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Input Tray Panel
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF060D09) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Attachment Icon
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.emeraldGreen),
                      onPressed: _showImagePickerSourceSelector,
                    ),
                    
                    // Voice Mic Icon
                    IconButton(
                      icon: const Icon(Icons.mic_none_outlined, color: AppTheme.emeraldGreen),
                      onPressed: _startVoiceInput,
                    ),
                    const SizedBox(width: 8),

                    // Text Input Field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) => _send(val),
                        decoration: InputDecoration(
                          hintText: 'Ask about soil, crops, weather...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          fillColor: isDark ? const Color(0xFF111D16) : const Color(0xFFF1F5F2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Send Button
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _send(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Listening overlay layer
          if (_isListening)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Pulse(
                        infinite: true,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppTheme.emeraldGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Listening for voice input...',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Say something like "How do I grow tomatoes?"',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBouncingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 3),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.emeraldGreen,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, ThemeData theme, bool isDark) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.emeraldGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🌱', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.emeraldGreen
                      : (isDark ? const Color(0xFF13251A) : const Color(0xFFE8F5E9)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Render image attachment if exists
                    if (message.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message.imagePath!),
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      message.text,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.4,
                        color: isUser 
                            ? Colors.white 
                            : (isDark ? const Color(0xFFE2E3DD) : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
