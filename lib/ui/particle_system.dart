import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../services/sneeze_detector.dart';

// The Particle Data Class
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; 
  bool isStuck;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    this.isStuck = false,
  });
}

// The Animation Controller Widget
class SneezeParticleSystem extends StatefulWidget {
  final SneezeReport report;

  const SneezeParticleSystem({super.key, required this.report});

  @override
  State<SneezeParticleSystem> createState() => _SneezeParticleSystemState();
}

class _SneezeParticleSystemState extends State<SneezeParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _isDirectHit = false;

  @override
  void initState() {
    super.initState();

    
    _isDirectHit = widget.report.blastVector.dx.abs() < 35.0;

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _isDirectHit ? 4500 : 3000),
    );

    _generateParticles();

    // The Physics Loop
    _animController.addListener(() {
      setState(() {
        for (var p in _particles) {
          if (p.isStuck) {
            p.position += p.velocity;
            if (_random.nextDouble() > 0.95) {
              p.velocity += const Offset(0, 0.15);
            }
            p.life -= 0.005;
          } else {
            p.position += p.velocity;
            p.velocity += const Offset(
              0,
              0.2,
            );
            p.life -= 0.01;
          }
        }
        _particles.removeWhere((p) => p.life <= 0);
      });
    });

    _animController.forward();
  }

  void _generateParticles() {
    final Offset origin = const Offset(200, 300);

    if (_isDirectHit) {
      // DIRECT HIT: SPLATTER THE SCREEN
      for (int i = 0; i < 200; i++) {
        final double offsetX = (_random.nextDouble() - 0.5) * 350;
        final double offsetY = (_random.nextDouble() - 0.5) * 500;

        _particles.add(
          Particle(
            position: Offset(origin.dx + offsetX, origin.dy + offsetY),
            velocity: Offset(0, _random.nextDouble() * 0.5 + 0.1),
            color: Colors.white.withValues(alpha: _random.nextDouble() * 0.6 + 0.2),
            size: _random.nextDouble() * 8 + 3, // Slightly larger globs
            life: 1.0,
            isStuck: true,
          ),
        );
      }
    } else {
      // SIDE SNEEZE: SLOW TRAJECTORY
      final double baseAngle = math.atan2(
        widget.report.blastVector.dy,
        widget.report.blastVector.dx,
      );

      for (int i = 0; i < 150; i++) {
        final double angleSpread = (_random.nextDouble() - 0.5) * 1.5;
        final double finalAngle = baseAngle + angleSpread;
        final double speed = _random.nextDouble() * 10 + 2;

        _particles.add(
          Particle(
            position: origin,
            velocity: Offset(
              math.cos(finalAngle) * speed,
              math.sin(finalAngle) * speed,
            ),
            color: Colors.white.withValues(alpha: _random.nextDouble() * 0.5 + 0.3),
            size: _random.nextDouble() * 5 + 1,
            life: 1.0,
            isStuck: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: DropletPainter(_particles),
    );
  }
}

// The Custom Painter
class DropletPainter extends CustomPainter {
  final List<Particle> particles;

  DropletPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.life > 0) {
        final paint = Paint()
          ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;

        // Draw the main droplet
        canvas.drawCircle(p.position, p.size, paint);
        if (p.isStuck) {
          final trailPaint = Paint()
            ..color = p.color.withValues(alpha: (p.life * 0.5).clamp(0.0, 1.0))
            ..strokeWidth = p.size * 0.8
            ..strokeCap = StrokeCap.round;

          canvas.drawLine(
            p.position,
            Offset(p.position.dx, p.position.dy - (p.velocity.dy * 15)),
            trailPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant DropletPainter oldDelegate) => true;
}
