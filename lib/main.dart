import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'config/theme.dart';
import 'providers/import.dart';
import 'providers/song_provider.dart'; // ✅ Add this import
import 'views/import.dart';
import 'services/import.dart';
import 'models/import.dart';
import 'widgets/mini_player/import.dart';

late final AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await initAudioService();

  runApp(MuKiksApp(audioHandler: _audioHandler));
}

class MuKiksApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MuKiksApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(audioHandler),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SongProvider(), // ✅ Provide SongProvider globally
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MuKiks',
        theme: darkTheme,
        home: const HomeInitializer(),
      ),
    );
  }
}

class HomeInitializer extends StatefulWidget {
  const HomeInitializer({super.key});

  @override
  State<HomeInitializer> createState() => _HomeInitializerState();
}

class _HomeInitializerState extends State<HomeInitializer> {
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  Future<void> _checkFirstLaunch() async {
    final songProvider = context.read<SongProvider>();

    try {
      final isFirst = await AppPreferences.isFirstLaunch();

      if (isFirst) {
        await songProvider.scanSongs(); // ✅ Use provider instead of _loadSongs
        await AppPreferences.setFirstLaunchDone();
      } else {
        await songProvider
            .quickScanSongs(); // ✅ Add quick scan method in provider
      }

      await context.read<PlaylistProvider>().loadPlaylists();

      setState(() {
        _loading = false;
        _errorMessage = null;
      });
    } catch (e, stack) {
      debugPrint('❌ Error during initialization: $e\n$stack');
      setState(() {
        _errorMessage = 'Failed to initialize MuKiks.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = context.watch<SongProvider>();

    if (_loading || songProvider.isScanning) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return Scaffold(
      body: HomeScreen(
        songs: songProvider.songs,
        onScanRequested: () => songProvider.scanSongs(), // ✅ Trigger full scan
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
