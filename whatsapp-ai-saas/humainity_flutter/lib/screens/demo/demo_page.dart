import 'package:flutter/material.dart';
import 'package:humainise_ai/screens/home/widgets/demo_section.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DemoSection(), // 🔥 FULLSCREEN
    );
  }
}
