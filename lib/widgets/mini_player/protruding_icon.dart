import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class ProtrudingIcon extends StatelessWidget {
  const ProtrudingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
