import 'package:flutter/material.dart';
import 'screens/content_view.dart';

void main() {
  runApp(const SaiKirthanApp());
}

class SaiKirthanApp extends StatelessWidget {
  const SaiKirthanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Om Sai Ram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ContentView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
