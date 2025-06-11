import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/core/import.dart'; // Ensure this is the correct path

class RotatingDisc extends StatefulWidget {
  const RotatingDisc({super.key});

  @override
  State<RotatingDisc> createState() => _RotatingDiscState();
}

class _RotatingDiscState extends State<RotatingDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPlaying = context.read<PlayerProvider>().isPlaying;
      if (isPlaying) {
        _controller.repeat();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPlaying = context.watch<PlayerProvider>().isPlaying;
    if (isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withOpacity(0.1),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.music_note, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
