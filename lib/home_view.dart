import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'Home');
              },
              child: const Text('Logout'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
