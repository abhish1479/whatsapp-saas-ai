import 'package:flutter/material.dart';
import '../api.dart';
import '../auth_service.dart';
import 'dashboard.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final bizCtrl = TextEditingController();
  bool isLogin = true;

  Future<void> submit() async {
    final path = isLogin ? "/auth/login" : "/auth/signup";
    final body = isLogin
        ? {"email": emailCtrl.text, "password": passCtrl.text}
        : {
            "business_name": bizCtrl.text,
            "email": emailCtrl.text,
            "password": passCtrl.text
          };
    final res = await Api.post(path, body);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data["token"] != null) {
      await AuthService.saveToken(data["token"]);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${res.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("LeadBot SaaS", style: TextStyle(fontSize: 28)),
        if (!isLogin)
          TextField(controller: bizCtrl, decoration: InputDecoration(labelText: "Business Name")),
        TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
        TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password")),
        SizedBox(height: 16),
        ElevatedButton(onPressed: submit, child: Text(isLogin ? "Login" : "Sign Up")),
        TextButton(
            onPressed: () => setState(() => isLogin = !isLogin),
            child: Text(isLogin ? "No account? Sign up" : "Have account? Login"))
      ]),
    )));
  }
}
