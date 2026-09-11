import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; 
import 'package:haachii/splash_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error fetching cameras: $e');
  }

  runApp(const HaachiiApp());
}

class HaachiiApp extends StatelessWidget {
  const HaachiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haachii',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}