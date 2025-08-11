import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double? fadeWidth;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.fadeWidth = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(text, style: style, overflow: TextOverflow.ellipsis);
        }

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent
              ],
              stops: const [0.0, 0.1, 0.9, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              text,
              style: style,
            ),
          ),
        );
      },
    );
  }
}
