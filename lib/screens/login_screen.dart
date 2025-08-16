import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = "login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool _isLoading = false;
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("login Successfully")));
      Navigator.pushNamed(context, ChatScreen.id);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("login screen")),
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
                style: TextStyle(color: Colors.black87),
                onChanged: (value) {
                  email = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: kTextFieldDecoration.copyWith(hintText: "Email"),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                style: TextStyle(color: Colors.black87),
                decoration: kTextFieldDecoration.copyWith(hintText: "Password"),
              ),
              SizedBox(height: 20),

              RoundedButton(
                buttonText: "Login",
                backgroundColor: Colors.lightBlue,
                onPress: _login,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
