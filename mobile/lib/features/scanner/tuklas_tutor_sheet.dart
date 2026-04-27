// mobile/lib/features/scanner/tuklas_tutor_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isAI;

  ChatMessage({required this.text, required this.isAI});

  // Helper to map to the backend schema
  Map<String, String> toBackendSchema() {
    return {"role": isAI ? "assistant" : "user", "content": text};
  }
}

Future<void> showTuklasTutorSheet(
  BuildContext context, {
  required String objectName,
  required String strand,
  required String currentCardContent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => TuklasTutorSheet(
      objectName: objectName,
      strand: strand,
      cardContent: currentCardContent,
    ),
  );
}

class TuklasTutorSheet extends StatefulWidget {
  final String objectName;
  final String strand;
  final String cardContent;

  const TuklasTutorSheet({
    super.key,
    required this.objectName,
    required this.strand,
    required this.cardContent,
  });

  @override
  State<TuklasTutorSheet> createState() => _TuklasTutorSheetState();
}

class _TuklasTutorSheetState extends State<TuklasTutorSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Contextual greeting based on the object
    _messages.add(
      ChatMessage(
        text:
            "Hi! I'm your Tuklas Tutor. I see you're learning about the ${widget.objectName}. What questions do you have?",
        isAI: true,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // Build the history array for the backend (excluding the current message we are about to send)
    final history = _messages.map((m) => m.toBackendSchema()).toList();

    setState(() {
      _messages.add(ChatMessage(text: text, isAI: false));
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    // 🚀 Call the actual Render Backend
    final aiReply = await ChatService.sendMessage(
      objectName: widget.objectName,
      strand: widget.strand,
      cardContent: widget.cardContent,
      message: text,
      history: history,
    );

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      if (aiReply != null) {
        _messages.add(ChatMessage(text: aiReply, isAI: true));
      } else {
        _messages.add(
          ChatMessage(
            text:
                "I'm having trouble connecting to the network right now. Please try again.",
            isAI: true,
          ),
        );
      }
    });

    _scrollToBottom();
  }

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
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle and Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tuklas Tutor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator(theme)
                          .animate()
                          .fade(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0);
                    }
                    return _buildChatBubble(_messages[index], theme)
                        .animate()
                        .fade(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
              ),

              // Input Area
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isTyping,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: _isTyping
                                  ? 'Tutor is thinking...'
                                  : 'Ask a question...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isTyping
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                )
                              : theme.colorScheme.primary,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _isTyping ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message, ThemeData theme) {
    final isAI = message.isAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAI) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary.withValues(
                alpha: 0.1,
              ),
              radius: 16,
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                    : theme.colorScheme.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: isAI
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAI ? 4 : 20),
                  bottomRight: Radius.circular(isAI ? 20 : 4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
            radius: 16,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Thinking...",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
