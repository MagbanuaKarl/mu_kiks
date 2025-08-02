import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/widgets/common/marquee_text.dart';

class SongMarquee extends StatelessWidget {
  final String title;

  const SongMarquee({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 20,
        child: MarqueeText(
          text: title,
          style: AppTextStyles.subhead.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
