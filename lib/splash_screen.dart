import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'ui/camera_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showText = false;
  late final AnimationController _lottieController;
  late final AnimationController _textController;

  final String _title = 'Haachii';

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _lottieController.addListener(() {
      if (_lottieController.lastElapsedDuration != null &&
          _lottieController.lastElapsedDuration!.inMilliseconds >= 40 &&
          !_showText) {
        setState(() {
          _showText = true;
        });

        _textController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 5000), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Sneeze Animation Layer
          Align(
            alignment: const Alignment(-0.4, 0.0),
            child: Lottie.asset(
              'assets/sneeze.json',
              controller: _lottieController,
              width: 250,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) _lottieController.forward();
                });
              },
            ),
          ),

          // Letter-by-Letter Circular Orbit Layer
          if (_showText)
            Align(
              alignment: const Alignment(-0.2, -0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_title.length, (index) {
                  final double start = index * 0.08;
                  final double end = (start + 0.45).clamp(0.0, 1.0);
                  final Animation<Offset> pathAnimation =
                      CubicBezierOffsetTween(
                        begin: const Offset(-20, 250),
                        control1: const Offset(300, 350),
                        control2: const Offset(350, -50),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _textController,
                          curve: Interval(
                            start,
                            end,
                            curve: Curves.easeInOutSine,
                          ),
                        ),
                      );

                  // The fade for each individual letter
                  final Animation<double> fadeAnimation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _textController,
                          curve: Interval(
                            start,
                            (start + 0.2).clamp(0.0, 1.0),
                            curve: Curves.easeIn,
                          ),
                        ),
                      );

                  return AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: pathAnimation.value,
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _title[index],
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom Tween to animate a pixel Offset along a Cubic Bézier curve (2 control points).
class CubicBezierOffsetTween extends Tween<Offset> {
  final Offset control1;
  final Offset control2;

  CubicBezierOffsetTween({
    required Offset begin,
    required this.control1,
    required this.control2,
    required Offset end,
  }) : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final double t1 = 1 - t;
    // Cubic Bézier formula applied to X/Y coordinates
    return Offset(
      t1 * t1 * t1 * begin!.dx +
          3 * t1 * t1 * t * control1.dx +
          3 * t1 * t * t * control2.dx +
          t * t * t * end!.dx,

      t1 * t1 * t1 * begin!.dy +
          3 * t1 * t1 * t * control1.dy +
          3 * t1 * t * t * control2.dy +
          t * t * t * end!.dy,
    );
  }
}
