import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  static const String id = "registration_screen";

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Screen")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: "logo",
                child: Material(
                  color: Colors.transparent,
                  child: const Text(
                    "⚡",
                    style: TextStyle(fontSize: 100),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black87),
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: "Email"),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                style: TextStyle(color: Colors.black87),
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: "Password"),
              ),
              SizedBox(height: 20),
              RoundedButton(
                buttonText: "Register",
                isLoading: _isLoading,
                backgroundColor: Colors.blueAccent,
                onPress: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("user creates successfully")),
                    );
                    Navigator.pushNamed(context, ChatScreen.id);
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
