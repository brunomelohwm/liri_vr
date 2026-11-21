import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:liri_vr/player_page.dart';
import 'package:video_360/video_360.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiriVRApp());
}

class LiriVRApp extends StatelessWidget {
  const LiriVRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liri VR',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Video360Controller? controller;
  String? videoPath;
  bool isPlaying = false;

  Future<void> selectVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    final path = result.single.path;
    if (path == null) {
      return;
    }

    setState(() {
      videoPath = path;
      isPlaying = true;
    });
  }

  void openPlayer() {
    if (videoPath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerPage(videoPath: videoPath!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vrpano, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'LIRI VR',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: selectVideo,
              icon: const Icon(Icons.folder_open),
              label: const Text('Selecionar vídeo MP4'),
            ),
            if (videoPath != null) ...[
              const SizedBox(height: 16),
              const Text('Vídeo selecionado'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: openPlayer,
                child: const Text('Reproduzir em 360°'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
