import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String id = "welcome_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      '⚡',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      " Flash Chat",

                      textStyle: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: Duration(milliseconds: 200),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                ),
              ],
            ),
            SizedBox(height: 48),
            RoundedButton(
              buttonText: "Login",
              onPress: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),

            SizedBox(height: 20),
            RoundedButton(
              buttonText: "Register",
              backgroundColor: Colors.blueAccent,
              onPress: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
            SizedBox(height: 20),

            RoundedButton(
              buttonText: "Chat screen",
              backgroundColor: Colors.blueAccent,
              onPress: () {
                Navigator.pushNamed(context, ChatScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
