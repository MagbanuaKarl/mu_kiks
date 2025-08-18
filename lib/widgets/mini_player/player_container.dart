import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class PlayerContainer extends StatelessWidget {
  final Widget protrudingIcon;
  final Widget songMarquee;
  final Widget controls;

  const PlayerContainer({
    super.key,
    required this.protrudingIcon,
    required this.songMarquee,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: screenWidth,
          margin: const EdgeInsets.only(left: 28, right: 12, top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 36), // for spacing after protruding icon
              Expanded(child: songMarquee),
              const SizedBox(width: 12),
              controls,
            ],
          ),
        ),
        Positioned(
          left: 8,
          top: 0,
          bottom: -15,
          child: Align(
            alignment: Alignment.center,
            child: protrudingIcon,
          ),
        ),
      ],
    );
  }
}
