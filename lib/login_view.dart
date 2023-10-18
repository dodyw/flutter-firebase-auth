import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/phone_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'home_view.dart';


class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneView()),
                );
              },
              child: const Text('Login with Phone'),
            ),
            ElevatedButton(
              onPressed: () {
                signInWithGoogle(context);
              },
              child: const Text('Login with Google'),
            ),
            ElevatedButton(
              onPressed: () {
                signInWithFacebook();
              },
              child: const Text('Login with Facebook'),
            ),
            const Spacer(),
          ],
        ),
      )
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Capture the context before entering the async block
    final currentContext = context;

    try {
      var loginResult = await FirebaseAuth.instance.signInWithCredential(credential);
      String? userIdToken = await loginResult.user?.getIdToken();
      print("userIdToken: $userIdToken");

      // Write token to text file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/firebase_token.txt');
      await file.writeAsString(userIdToken!);
      print("File written to ${file.path}");

      // Navigate to HomeView using the captured context
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (currentContext) => HomeView()), // Replace 'HomeView' with your actual HomeView class
      );
    } catch (e) {
      // Handle any errors that occur during Google sign-in
      print("Error signing in with Google: $e");
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

    // Access the user's UID
    String uid = userCredential.user!.uid;

    // Access the user's ID token
    String? userIdToken = await userCredential.user!.getIdToken();
    print("userIdToken: $userIdToken");

    return userCredential;
  }
}
