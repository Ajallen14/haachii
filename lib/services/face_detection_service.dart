import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    // Configure ML Kit specifically for our hackathon needs
    final options = FaceDetectorOptions(
      enableTracking: true,       // Essential for calculating trajectory vectors
      enableClassification: true, // Essential for detecting the eye-squeeze
      performanceMode: FaceDetectorMode.fast, // We need speed over extreme precision
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<List<Face>> processImage(InputImage inputImage) async {
    return await _faceDetector.processImage(inputImage);
  }

  void dispose() {
    _faceDetector.close();
  }
}