import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async'; // Required for Future.delayed

// --- 1. MESSAGE DATA MODEL ---
class ChatMessage {
  final String text;
  final bool isAI;

  ChatMessage({required this.text, required this.isAI});
}

class TuklasTutorScreen extends StatefulWidget {
  const TuklasTutorScreen({super.key});

  @override
  State<TuklasTutorScreen> createState() => _TuklasTutorScreenState();
}

class _TuklasTutorScreenState extends State<TuklasTutorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- 2. CHAT STATE & PLACEHOLDERS ---
  bool _isTyping = false;
  int _aiResponseIndex = 0;

  // The chat starts with just the greeting
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hi! How can I help you today?", isAI: true),
  ];

  // The queue of placeholder responses the AI will cycle through
  final List<String> _placeholderResponses = [
    "Magellan's Cross is a historic Christian cross planted by Ferdinand Magellan in 1521, marking the arrival of Christianity in the Philippines.",
    "You can take a taxi or Grab (~₱250–₱400) or ride a bus/jeepney toward Cebu City, then walk a few minutes to the plaza where the cross is located.",
    "That's a fascinating topic! The science behind it involves a mix of physics and material properties. Would you like to dive deeper?",
    "I can help you create a learning pathway for that. Should we add it to your Kaalaman Skill Tree?",
  ];

  // --- 3. SEND MESSAGE LOGIC ---
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // 1. Add User Message
    setState(() {
      _messages.add(ChatMessage(text: text, isAI: false));
      _isTyping = true; // Trigger the AI typing indicator
    });

    _textController.clear();
    _scrollToBottom();

    // 2. Simulate AI "Thinking" for 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // 3. Add AI Placeholder Response
      setState(() {
        _isTyping = false; // Hide typing indicator
        
        // Grab the next response in the queue, looping back to start if we run out
        String aiReply = _placeholderResponses[_aiResponseIndex % _placeholderResponses.length];
        _messages.add(ChatMessage(text: aiReply, isAI: true));
        
        _aiResponseIndex++;
      });

      _scrollToBottom();
    });
  }

  // Helper to smoothly scroll to the newest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive Background Gradient
    final List<Color> bgGradient = isDark 
        ? const [Color(0xFF121212), Color(0xFF050505)]
        : const [Color(0xFFFFFDF4), Color(0xFFD9D7CE)];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary), // Themed Icon
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
            children: [
              TextSpan(text: 'Tuklas ', style: TextStyle(color: theme.colorScheme.primary)), // Themed Blue
              TextSpan(text: 'Tutor', style: TextStyle(color: theme.colorScheme.secondary)), // Themed Orange
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient, // Themed Background Gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 4. CHAT LIST ---
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  // Add 1 to itemCount if AI is typing to show the indicator
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Render the typing indicator at the very bottom
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator(theme)
                          .animate()
                          .fade(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
                    }

                    // Render normal messages
                    final msg = _messages[index];
                    return _buildChatBubble(msg, theme, isDark)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                  },
                ),
              ),

              // --- 5. BOTTOM INPUT AREA ---
              _buildInputArea(theme, bgGradient),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildChatBubble(ChatMessage message, ThemeData theme, bool isDark) {
    final isAI = message.isAI;

    // Green color for user bubble border, adapting for dark/light mode
    final userBorderColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) _buildAvatar(isAI: true, theme: theme),
          if (isAI) const SizedBox(width: 12),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(1.5), 
              decoration: BoxDecoration(
                gradient: isAI
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary], // Themed AI Border
                      )
                    : null,
                color: isAI ? null : userBorderColor, // Themed User Border
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isAI ? 4 : 24),
                  bottomRight: Radius.circular(isAI ? 24 : 4),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface, // Themed Surface Background
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(23),
                    topRight: const Radius.circular(23),
                    bottomLeft: Radius.circular(isAI ? 3 : 23),
                    bottomRight: Radius.circular(isAI ? 23 : 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        // Replaced hardcoded dark red with a vibrant theme-based gradient
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        isAI ? 'Tuklas Tutor' : 'You',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9), // Themed Text
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (!isAI) const SizedBox(width: 12),
          if (!isAI) _buildAvatar(isAI: false, theme: theme),
        ],
      ),
    );
  }

  // Simulated "Typing..." bubble
  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(isAI: true, theme: theme),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // Themed Background
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)), // Themed Border
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.secondary, // Themed Loader
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Typing...",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7), // Themed text
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isAI, required ThemeData theme}) {
    final color = isAI ? theme.colorScheme.primary : theme.colorScheme.secondary;
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(
        isAI ? Icons.auto_awesome : Icons.person,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, List<Color> bgGradient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: bgGradient, // Blends seamlessly into the scaffold background
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(1.5), 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.colorScheme.tertiary, theme.colorScheme.secondary], // Themed Input Border
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface, // Themed Input Background
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isTyping, 
                  style: TextStyle(color: theme.colorScheme.onSurface), // Themed input text
                  decoration: InputDecoration(
                    hintText: _isTyping ? 'Tuklas Tutor is replying...' : 'Ask a question...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)), // Themed hint
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Themed send button states
                colors: _isTyping 
                    ? [theme.colorScheme.onSurface.withValues(alpha: 0.2), theme.colorScheme.onSurface.withValues(alpha: 0.4)] 
                    : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)], 
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isTyping ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}