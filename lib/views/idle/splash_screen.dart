import 'package:flutter/material.dart';
import 'package:ocr_license_plate/constant/route.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    toLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(248, 215, 166, 1),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: Image.asset(
                    'assets/Lify_logo.jpg', // Replace with your logo image path
                    width: 150, // Set the width of the logo as per your design
                    height:
                        150, // Set the height of the logo as per your design
                  ),
                ),
                Text(
                  'LICENSE IDENTIFY',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  color: Colors.black,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> toLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
  }
}
