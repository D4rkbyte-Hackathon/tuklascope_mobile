import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/chat_service.dart';
import '../../core/widgets/tutor_markdown_text.dart';

class ChatMessage {
  final String text;
  final bool isAI;

  ChatMessage({required this.text, required this.isAI});

  Map<String, String> toBackendSchema() {
    return {"role": isAI ? "assistant" : "user", "content": text};
  }
}

Future<void> navigateToTuklasTutor(
  BuildContext context, {
  required String objectName,
  required String strand,
  required String currentCardContent,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TuklasTutorScreen(
        objectName: objectName,
        strand: strand,
        cardContent: currentCardContent,
      ),
    ),
  );
}

class TuklasTutorScreen extends StatefulWidget {
  final String objectName;
  final String strand;
  final String cardContent;

  const TuklasTutorScreen({
    super.key,
    required this.objectName,
    required this.strand,
    required this.cardContent,
  });

  @override
  State<TuklasTutorScreen> createState() => _TuklasTutorScreenState();
}

class _TuklasTutorScreenState extends State<TuklasTutorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: "UPLINK ESTABLISHED. I am your Tuklas Tutor. I see you're analyzing the [${widget.objectName.toUpperCase()}]. What queries do you require assistance with?",
        isAI: true,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final history = _messages.map((m) => m.toBackendSchema()).toList();

    setState(() {
      _messages.add(ChatMessage(text: text, isAI: false));
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

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
            text: "ERROR 404: Network uplink severed. Please attempt transmission again.",
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
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 16),
                  ),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy_rounded, color: theme.colorScheme.secondary, size: 20)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 1.seconds),
                  const SizedBox(width: 8),
                  Text(
                    'TUKLAS HERO TUTOR',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.secondary.withValues(alpha: 0.5),
                        Colors.transparent,
                      ]
                    )
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.03),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.03 : 0.06,
              child: CustomPaint(painter: _GridPainter(color: theme.colorScheme.onSurface)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                _buildInputArea(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, ThemeData theme) {
    final isAI = message.isAI;
    final accentColor = isAI ? theme.colorScheme.secondary : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAI) ...[
                Icon(Icons.hub_rounded, size: 14, color: accentColor),
                const SizedBox(width: 6),
              ],
              Text(
                isAI ? 'SYSTEM // AI TUTOR' : 'USER // TRANSMISSION',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: accentColor.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                ),
              ),
              if (!isAI) ...[
                const SizedBox(width: 6),
                Icon(Icons.radar_rounded, size: 14, color: accentColor),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // FIX BUG: Layout side indicator separately using IntrinsicHeight + Row
          // to fully prevent complex cross-border paint breakdown crashes
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAI)
                    Container(
                      width: 3.5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
                      ),
                    ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isAI ? 4 : 20),
                          topRight: Radius.circular(isAI ? 20 : 4),
                          bottomLeft: const Radius.circular(20),
                          bottomRight: const Radius.circular(20),
                        ),
                      ),
                      child: TutorMarkdownText(
                        data: message.text,
                        textColor: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  if (!isAI)
                    Container(
                      width: 3.5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hub_rounded, size: 14, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                'SYSTEM // AI TUTOR',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "PROCESSING_DATALOG...",
                        style: GoogleFonts.orbitron(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isTyping,
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: _isTyping ? 'AWAITING RESPONSE...' : 'ENTER TRANSMISSION...',
                      hintStyle: GoogleFonts.orbitron(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                      border: InputBorder.none,
                      icon: Icon(Icons.terminal_rounded, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isTyping ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isTyping 
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1) 
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isTyping ? [] : [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: _isTyping ? theme.colorScheme.onSurface.withValues(alpha: 0.3) : theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}