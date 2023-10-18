import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'home_view.dart';

class PhoneView extends StatelessWidget {
  PhoneView({Key? key}) : super(key: key);
  final controller = Get.put(PhoneController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Phone'),
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.grey,
          body: Center(
              child: Column(
                  children: [
                    const Spacer(),
                    (controller.showVerificationCode.value) ?
                      phoneVerificationForm(context) : phoneNumberForm(context),
                    const Spacer(),
                  ]
              )
          )
      );
    });
  }

  phoneNumberForm(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
                fontSize: 16.0, color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              fillColor: Colors.white,
              // Background color
              filled: true,
              contentPadding: const EdgeInsets.all(16.0),
              // Padding
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey,
                    width: 2.0), // Border when not focused
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey,
                    width: 2.0), // Border when focused
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            controller.sendPhoneNumber();
          },
          child: const Text('Login with Phone'),
        ),
      ]
    );
  }

  phoneVerificationForm(BuildContext context) {
    return Column(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller.phoneVerificationCodeController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontSize: 16.0, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Enter verification code',
                fillColor: Colors.white,
                // Background color
                filled: true,
                contentPadding: const EdgeInsets.all(16.0),
                // Padding
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey,
                      width: 2.0), // Border when not focused
                  borderRadius: BorderRadius.circular(
                      8.0), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey,
                      width: 2.0), // Border when focused
                  borderRadius: BorderRadius.circular(
                      8.0), // Rounded corners
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.sendVerificationCode(context);
            },
            child: const Text('Verify Code'),
          ),
        ]
    );
  }
}

class PhoneController extends GetxController {
  var showVerificationCode = false.obs;
  var phoneNumberController = TextEditingController();
  var phoneVerificationCodeController = TextEditingController();

  var verificationId;
  var resendToken;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> sendPhoneNumber() async {
    await auth.verifyPhoneNumber(
      phoneNumber: '+6282231068140',
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("verificationCompleted");

        // android only
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("verificationFailed");
      },
      codeSent: (String verificationId, int? resendToken) {
        showVerificationCode.value = true;
        this.verificationId = verificationId;
        this.resendToken = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout");
      },
    );
  }

  Future<void> sendVerificationCode(BuildContext context) async {
    // Update the UI - wait for the user to enter the SMS code
    String smsCode = phoneVerificationCodeController.text;

    final currentContext = context;

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

    var loginResult = await auth.signInWithCredential(credential);
    String? userIdToken = await loginResult.user?.getIdToken();
    print("userIdToken: $userIdToken");

    // Write token to text file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/firebase_token.txt');
    await file.writeAsString(userIdToken!);
    print("File written to ${file.path}");

    // Navigate to HomeView using the captured context
    showVerificationCode.value = false;
    Navigator.push(
      currentContext,
      MaterialPageRoute(builder: (currentContext) => HomeView()), // Replace 'HomeView' with your actual HomeView class
    );
  }
}