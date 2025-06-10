import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/import.dart';
import 'views/import.dart';
import 'services/import.dart';
import 'models/import.dart';
import 'widgets/import.dart';

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
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
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
    await Provider.of<PlaylistProvider>(context, listen: false).loadPlaylists();

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

    return Stack(
      children: [
        HomeScreen(songs: _songs),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MiniPlayer(),
        ),
      ],
    );
  }
}
