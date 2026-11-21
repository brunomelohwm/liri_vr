import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_360/video_360.dart';

class PlayerPage extends StatefulWidget {
  final String videoPath;

  const PlayerPage({super.key, required this.videoPath});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Video360Controller? controller;
  bool isPlaying = false;
  bool showControls = true;
  Timer? controlsTimer;
  bool isSbs = false;

  void showControlsTemporarily() {
    controlsTimer?.cancel();

    setState(() {
      showControls = true;
    });

    if (isPlaying) {
      controlsTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;

        setState(() {
          showControls = false;
        });
      });
    }
  }

  void hideControlsTimer() {
    controlsTimer?.cancel();
  }

  Future<void> togglePlayback() async {
    final videoController = controller;
    if (videoController == null) return;

    final shouldPlay = !isPlaying;

    setState(() {
      isPlaying = shouldPlay;
      showControls = true;
    });

    if (shouldPlay) {
      await videoController.play();
      showControlsTemporarily();
    } else {
      hideControlsTimer();
      await videoController.stop();
    }
  }

  Future<void> toggleStereoMode() async {
    final videoController = controller;
    if (videoController == null) return;

    final newMode = !isSbs;

    setState(() {
      isSbs = newMode;
    });

    await videoController.setStereoMode(newMode ? 2 : 3);
  }

  @override
  void dispose() {
    controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerDown: (_) {
          showControlsTemporarily();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Video360View(
                url: widget.videoPath,
                isRepeat: true,
                onVideo360ViewCreated: (value) {
                  controller = value;
                  controller?.play();

                  if (mounted) {
                    setState(() {
                      isPlaying = true;
                    });

                    showControlsTemporarily();
                  }
                },
              ),
            ),

            if (showControls) ...[
              Positioned(
                top: 32,
                left: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    controller?.stop();
                    Navigator.pop(context);
                  },
                ),
              ),

              // Botão Play/Pause
              Positioned(
                bottom: 35,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 38,
                      padding: const EdgeInsets.all(16),
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: togglePlayback,
                    ),
                  ),
                ),
              ),
              // Botão de modo SBS
              Positioned(
                bottom: 45,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Alternar modo SBS',
                    icon: Icon(
                      Icons.view_week_rounded,
                      color: isSbs ? Colors.greenAccent : Colors.white,
                      size: 28,
                    ),
                    onPressed: toggleStereoMode,
                  ),
                ),
              ),
            ],

            // Botão voltar
          ],
        ),
      ),
    );
  }
}
