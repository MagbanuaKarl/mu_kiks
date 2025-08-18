// lib/services/audio_handler.dart

import 'package:audio_service/audio_service.dart';
import 'audio_player_handler.dart';

/// Initializes the background audio service using [AudioPlayerHandler].
Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.mu_kiks',
      androidNotificationChannelName: 'MuKiks Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );
}
