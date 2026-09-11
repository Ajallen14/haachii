import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
          _lottieController.lastElapsedDuration!.inMilliseconds >= 45 &&
          !_showText) {
        setState(() {
          _showText = true;
        });
        _textController.forward();
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

          // Letter-by-Letter Orbit Layer
          if (_showText)
            Align(
              alignment: const Alignment(-0.2, -0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_title.length, (index) {
                  final double start = index * 0.1;
                  final double end = (start + 0.4).clamp(0.0, 1.0);

                  // The path for each individual letter
                  final Animation<Offset> pathAnimation =
                      BezierOffsetTween(
                        begin: const Offset(150, 350),
                        control: const Offset(450, -50),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _textController,
                          curve: Interval(
                            start,
                            end,
                            curve: Curves.easeOutCubic,
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

/// Custom Tween to animate a pixel Offset along a Quadratic Bézier curve.
class BezierOffsetTween extends Tween<Offset> {
  final Offset control;

  BezierOffsetTween({
    required Offset begin,
    required this.control,
    required Offset end,
  }) : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final double t1 = 1 - t;
    return Offset(
      t1 * t1 * begin!.dx + 2 * t1 * t * control.dx + t * t * end!.dx,
      t1 * t1 * begin!.dy + 2 * t1 * t * control.dy + t * t * end!.dy,
    );
  }
}
