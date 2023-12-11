import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:socdoc_flutter/Pages/OnBoardingPage.dart';

import 'package:socdoc_flutter/Utils/AuthUtil.dart';
import 'package:socdoc_flutter/Utils/SocdocAuthProvider.dart';

import 'package:socdoc_flutter/firebase_options.dart';
import 'package:socdoc_flutter/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginNeeded = false;
  SocdocAppState? socdocApp;

  @override
  void initState() {
    super.initState();
    checkLastLogin();
  }

  @override
  Widget build(BuildContext context) {
    socdocApp = context.findAncestorStateOfType<SocdocAppState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: (
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LoginLogo(),
                _isLoginNeeded ? _LoginButtons() : const SizedBox.shrink()
              ],
            )
          ),
        )
      )
    );
  }

  void checkLastLogin() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) async {
        if(user != null && socdocApp != null){
          socdocApp!.setState(() {
            context.read<SocdocAuthProvider>().updateUser();
            socdocApp!.isLoggedIn = true;
          });
        }else if(mounted){
          setState(() {
            _isLoginNeeded = true;
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OnBoardingPage()));
          });
        }
      });
  }
}

class _LoginButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 200.0,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: double.infinity,
            child: SignInButton(
              Buttons.google,
              text: "   Sign In with Google",
              onPressed: () {
                tryLogin(context, 0);
              }
            )
          ),
        ),
        Platform.isIOS ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: double.infinity,
            child: SignInButton(
              Buttons.apple,
              text: "   Sign In with Apple",
              onPressed: () {
                tryLogin(context, 1);
              }
            )
          ),
        ):const SizedBox.shrink()
      ]
    );
  }
}

class _LoginLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250.0,
      child: Image(
        fit: BoxFit.fill,
        image: AssetImage('assets/socdoc_title_logo.png')
      ),
    );
  }
}