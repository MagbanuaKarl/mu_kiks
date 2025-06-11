import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final bool alwaysScroll;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 10),
    this.alwaysScroll = false,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflowAndScroll();
    });
  }

  void _checkOverflowAndScroll() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final boxWidth = renderBox?.size.width ?? 0;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.size.width;
    final shouldScroll = widget.alwaysScroll || textWidth > boxWidth;

    if (shouldScroll) {
      setState(() => _isOverflowing = true);
      while (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.duration,
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.05, 0.95, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}
