import 'package:flutter/material.dart';

import 'splash_screen.dart';

void main() {
  runApp(const HaachiiApp());
}

class HaachiiApp extends StatelessWidget {
  const HaachiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haachii',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
