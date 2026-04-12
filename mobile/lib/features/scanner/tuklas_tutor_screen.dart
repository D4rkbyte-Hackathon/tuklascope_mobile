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

  // Core Theme Colors
  final Color primaryBlue = const Color(0xFF0B3C6A);
  final Color accentOrange = const Color(0xFFFF6B2C);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color textLight = const Color(0xFF4A4A4A);
  final Color bgLight = const Color(0xFFFFFDF4);
  final Color bgDark = const Color(0xFFD9D7CE);

  // --- 2. CHAT STATE & PLACEHOLDERS ---
  bool _isTyping = false;
  int _aiResponseIndex = 0;

  // The chat starts with just the greeting
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hi! How can I help you today?", isAI: true),
  ];

  // The queue of placeholder responses the AI will cycle through
  final List<String> _placeholderResponses = [
    "Notebooks is a historic Christian cross planted by Ferdinand Magellan in 1521, marking the arrival of Christianity in the Philippines.",
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlue),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
            children: [
              TextSpan(text: 'Tuklas ', style: TextStyle(color: primaryBlue)),
              TextSpan(text: 'Tutor', style: TextStyle(color: accentOrange)),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgLight, bgDark],
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
                      return _buildTypingIndicator()
                          .animate()
                          .fade(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
                    }

                    // Render normal messages
                    final msg = _messages[index];
                    return _buildChatBubble(msg)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                  },
                ),
              ),

              // --- 5. BOTTOM INPUT AREA ---
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildChatBubble(ChatMessage message) {
    final isAI = message.isAI;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) _buildAvatar(isAI: true),
          if (isAI) const SizedBox(width: 12),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(1.5), 
              decoration: BoxDecoration(
                gradient: isAI
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primaryBlue, accentOrange],
                      )
                    : null,
                color: isAI ? null : darkGreen, 
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
                  color: Colors.white,
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
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2B0E0E), Color(0xFF571717)], 
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
                        color: textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (!isAI) const SizedBox(width: 12),
          if (!isAI) _buildAvatar(isAI: false),
        ],
      ),
    );
  }

  // Simulated "Typing..." bubble
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(isAI: true),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Typing...",
                  style: TextStyle(
                    color: textLight,
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

  Widget _buildAvatar({required bool isAI}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAI ? primaryBlue.withOpacity(0.1) : accentOrange.withOpacity(0.1),
        border: Border.all(color: isAI ? primaryBlue.withOpacity(0.3) : accentOrange.withOpacity(0.3)),
      ),
      child: Icon(
        isAI ? Icons.auto_awesome : Icons.person,
        color: isAI ? primaryBlue : accentOrange,
        size: 20,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgLight, bgDark],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(1.5), 
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF6B2C), Color(0xFFAC402B)], 
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  // Disable input slightly while AI is typing to prevent spamming
                  enabled: !_isTyping, 
                  style: TextStyle(color: textLight),
                  decoration: InputDecoration(
                    hintText: _isTyping ? 'Tuklas Tutor is replying...' : 'Ask a question...',
                    hintStyle: TextStyle(color: textLight.withOpacity(0.5)),
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
                // Gray out the button if AI is typing
                colors: _isTyping 
                    ? [Colors.grey[400]!, Colors.grey[600]!] 
                    : [const Color(0xFF64B5F6), const Color(0xFF3171A4)], 
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