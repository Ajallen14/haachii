import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WiperVideoOverlay extends StatefulWidget {
  final VoidCallback? onComplete;

  const WiperVideoOverlay({super.key, this.onComplete});

  @override
  State<WiperVideoOverlay> createState() => _WiperVideoOverlayState();
}

class _WiperVideoOverlayState extends State<WiperVideoOverlay>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isTransitioningOut = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/sivani.mp4');

    try {
      await _videoController.initialize();
      await _videoController.setLooping(false);

      if (!mounted) return;

      // Start playing and fade the video in
      await _videoController.play();
      _fadeController.forward();

      // Monitor playback to trigger the fade-out near the end
      _videoController.addListener(_checkVideoProgress);
      setState(() {});
    } catch (e) {
      debugPrint('Error loading wiper video: $e');
    }
  }

  void _checkVideoProgress() {
    if (!_videoController.value.isInitialized) return;

    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    // Trigger transition out 600ms before video ends (matching fade duration)
    if (!_isTransitioningOut &&
        duration > Duration.zero &&
        position >= (duration - const Duration(milliseconds: 600))) {
      _isTransitioningOut = true;
      _fadeController.reverse().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_checkVideoProgress);
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoController.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }
}
