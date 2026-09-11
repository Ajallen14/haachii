import 'package:flutter/material.dart';

import 'home.dart';

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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
