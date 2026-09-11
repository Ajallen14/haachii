import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  
  // Decibel threshold for a loud noise (0 is max volume, -160 is silence)
  // You may need to tweak this value during testing!
  final double sneezeThreshold = -10.0; 

  Future<void> startTripwire({required VoidCallback onLoudNoise}) async {
    if (await _audioRecorder.hasPermission()) {
      // Start a low-quality stream just to read the amplitude data
      await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      
      // Check the amplitude every 100 milliseconds
      _amplitudeSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((Amplitude amp) {
            
        // If the noise spikes past our threshold, trigger the callback
        if (amp.current > sneezeThreshold) {
          debugPrint('AUDIO TRIPWIRE TRIGGERED! Amplitude: ${amp.current}');
          onLoudNoise();
        }
      });
    }
  }

  Future<void> dispose() async {
    await _amplitudeSubscription?.cancel();
    await _audioRecorder.dispose();
  }
}
