import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(LeadBotApp());
}

class LeadBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "LeadBot SaaS",
        theme: ThemeData(primarySwatch: Colors.red),
        home: LoginScreen());
  }
}
