import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ContainmentReport extends StatefulWidget {
  final VoidCallback onReset;

  const ContainmentReport({super.key, required this.onReset});

  @override
  State<ContainmentReport> createState() => _ContainmentReportState();
}

class _ContainmentReportState extends State<ContainmentReport> {
  bool _showAction = false;
  bool _showButton = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 15),
              const Text(
                'CONTAINMENT BREACH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 30),

              // The Typewriter Animation for the Stats
              SizedBox(
                height: 180,
                width: double.infinity,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Courier',
                    height: 1.6,
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                    onFinished: () {
                      if (mounted) {
                        setState(() {
                          _showAction = true;
                          _showButton = true;
                        });
                      }
                    },
                    animatedTexts: [
                      TypewriterAnimatedText(
                        '> Droplet Count: ~40,000\n'
                        '> Screen Contamination: 94% (Critical)\n'
                        '> Threat Level: Bio-Hazard Level 4\n'
                        '> Collateral Damage: 0 Bystanders',
                        speed: const Duration(milliseconds: 35),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // The Punchline
              AnimatedOpacity(
                opacity: _showAction ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Recommended Action: Burn the device. It belongs to the virus now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Reset Button
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: ElevatedButton.icon(
                  onPressed: _showButton ? widget.onReset : null,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'RESUME SCANNING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
