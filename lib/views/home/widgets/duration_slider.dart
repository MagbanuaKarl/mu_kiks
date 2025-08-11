import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/import.dart';

class DurationSlider extends StatefulWidget {
  const DurationSlider({super.key});

  @override
  State<DurationSlider> createState() => _DurationSliderState();
}

class _DurationSliderState extends State<DurationSlider> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final position = player.currentPosition;
        final total = player.totalDuration;

        final isValid = total > Duration.zero;

        // Use drag value if currently dragging, otherwise use actual position
        final currentValue = _isDragging
            ? _dragValue
            : (isValid ? position.inMilliseconds.toDouble() : 0.0);

        // Calculate progress percentage for display
        // final progressPercent = isValid && total.inMilliseconds > 0
        //     ? (currentValue / total.inMilliseconds * 100).clamp(0.0, 100.0)
        //     : 0.0;

        return Column(
          children: [
            // Progress indicator text (optional)
            // if (isValid)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           '${progressPercent.toStringAsFixed(1)}%',
            //           style:
            //               const TextStyle(fontSize: 10, color: Colors.white54),
            //         ),
            //       ],
            //     ),
            //   ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.grey.shade400,
                thumbColor: Colors.blueAccent,
                overlayColor: Colors.blueAccent.withOpacity(0.2),
              ),
              child: Slider(
                value: isValid
                    ? currentValue.clamp(0.0, total.inMilliseconds.toDouble())
                    : 0.0,
                max: isValid ? total.inMilliseconds.toDouble() : 1.0,
                onChangeStart: isValid
                    ? (value) {
                        setState(() {
                          _isDragging = true;
                          _dragValue = value;
                        });
                      }
                    : null,
                onChanged: isValid
                    ? (value) {
                        setState(() {
                          _dragValue = value;
                        });
                      }
                    : null,
                onChangeEnd: isValid
                    ? (value) async {
                        setState(() {
                          _isDragging = false;
                        });
                        await player
                            .seek(Duration(milliseconds: value.round()));
                      }
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_isDragging
                        ? Duration(milliseconds: _dragValue.round())
                        : position),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    _formatDuration(total),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
