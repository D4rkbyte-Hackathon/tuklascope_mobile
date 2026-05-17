import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

/// Normalizes AI/API copy so common markdown patterns parse correctly.
String prepareTutorMarkdown(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return text;

  text = text.replaceAll(r'\*\*', '**');
  text = text.replaceAll(r'\*', '*');
  text = text.replaceAll(r'\_\_', '__');

  text = text.replaceAllMapped(
    RegExp(r'\*\*\s+([^*]+?)\s+\*\*'),
    (match) => '**${match[1]!.trim()}**',
  );

  // Drop stray markers when bold is not properly closed.
  if (RegExp(r'\*\*').allMatches(text).length.isOdd) {
    text = text.replaceAll('**', '');
  }

  return text;
}

bool _usesBlockMarkdown(String text) {
  return RegExp(r'^#{1,6}\s', multiLine: true).hasMatch(text) ||
      RegExp(r'^\s*[-*+]\s', multiLine: true).hasMatch(text) ||
      text.contains('\n- ') ||
      text.contains('\n* ') ||
      text.contains('```');
}

List<InlineSpan> _inlineMarkdownSpans(String text, TextStyle base) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'(\*\*.+?\*\*|__.+?__|\*.+?\*|_.+?_)');
  var cursor = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start), style: base));
    }

    final token = match.group(0)!;
    String inner;
    TextStyle style = base;

    if (token.startsWith('**') && token.endsWith('**')) {
      inner = token.substring(2, token.length - 2);
      style = base.copyWith(fontWeight: FontWeight.w700);
    } else if (token.startsWith('__') && token.endsWith('__')) {
      inner = token.substring(2, token.length - 2);
      style = base.copyWith(fontWeight: FontWeight.w700);
    } else if (token.startsWith('*') && token.endsWith('*')) {
      inner = token.substring(1, token.length - 1);
      style = base.copyWith(fontStyle: FontStyle.italic);
    } else if (token.startsWith('_') && token.endsWith('_')) {
      inner = token.substring(1, token.length - 1);
      style = base.copyWith(fontStyle: FontStyle.italic);
    } else {
      inner = token;
    }

    spans.add(TextSpan(text: inner, style: style));
    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: base));
  }

  return spans;
}

/// Renders tutor / deck copy with markdown (bold, lists, headings, etc.).
class TutorMarkdownText extends StatelessWidget {
  final String data;
  final Color textColor;
  final double fontSize;
  final double lineHeight;

  const TutorMarkdownText({
    super.key,
    required this.data,
    required this.textColor,
    this.fontSize = 15,
    this.lineHeight = 1.55,
  });

  @override
  Widget build(BuildContext context) {
    final markdown = prepareTutorMarkdown(data);
    final baseStyle = GoogleFonts.inter(
      fontSize: fontSize,
      height: lineHeight,
      color: textColor,
    );

    if (!_usesBlockMarkdown(markdown)) {
      return SelectableText.rich(
        TextSpan(children: _inlineMarkdownSpans(markdown, baseStyle)),
      );
    }

    return MarkdownBody(
      data: markdown,
      shrinkWrap: true,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        h1: baseStyle.copyWith(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w800,
        ),
        h2: baseStyle.copyWith(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w700,
        ),
        h3: baseStyle.copyWith(
          fontSize: fontSize + 1,
          fontWeight: FontWeight.w700,
        ),
        listBullet: baseStyle,
        blockSpacing: 8,
        listIndent: 20,
        blockquote: baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: textColor.withValues(alpha: 0.75),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: textColor.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
        ),
        code: GoogleFonts.jetBrainsMono(
          fontSize: fontSize - 1,
          color: textColor,
          backgroundColor: textColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
