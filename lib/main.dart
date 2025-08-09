import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'config/theme.dart';
import 'providers/import.dart';
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
  List<Song> _songs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await AppPreferences.isFirstLaunch();
    if (isFirst) {
      await _loadSongs();
      await AppPreferences.setFirstLaunchDone();
    } else {
      // Not first launch → skip auto scan
      await Provider.of<PlaylistProvider>(context, listen: false)
          .loadPlaylists();
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await MusicScanner.scanAndImportSongs();
      await Provider.of<PlaylistProvider>(context, listen: false)
          .loadPlaylists();

      setState(() {
        _songs = songs;
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('❌ Failed to load songs: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: HomeScreen(
        songs: _songs,
        onScanRequested: _loadSongs, // ✅ pass scan trigger to HomeScreen
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
