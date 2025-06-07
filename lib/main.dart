import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/player_provider.dart';
import 'views/home/home_screen.dart';
import 'services/music_scanner.dart';
import 'models/song_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuKiksApp());
}

class MuKiksApp extends StatelessWidget {
  const MuKiksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
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
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await MusicScanner.scanAndImportSongs();
    setState(() {
      _songs = songs;
      _loading = false;
    });
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
    return HomeScreen(songs: _songs);
  }
}
