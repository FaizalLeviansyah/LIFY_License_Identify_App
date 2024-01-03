import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ocr_license_plate/views/idle/loading.dart';
import 'package:ocr_license_plate/views/idle/splash_screen.dart';
import 'package:ocr_license_plate/views/plates/plates_history_view.dart';
import 'package:ocr_license_plate/views/plates/plates_list_view.dart';
import 'package:ocr_license_plate/views/scan/scan_view.dart';

import 'constant/route.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/verify_email_view.dart';
import 'views/layout_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'September',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFFD8AF6A,
          <int, Color>{
            50: Color.fromRGBO(248, 215, 166, 1),
            100: Color.fromRGBO(248, 215, 166, 1),
            200: Color.fromRGBO(248, 215, 166, 1),
            300: Color.fromRGBO(248, 215, 166, 1),
            400: Color.fromRGBO(248, 215, 166, 1),
            500: Color.fromRGBO(248, 215, 166, 1),
            600: Color.fromRGBO(248, 215, 166, 1),
            700: Color.fromRGBO(248, 215, 166, 1),
            800: Color.fromRGBO(248, 215, 166, 1),
            900: Color.fromRGBO(248, 215, 166, 1),
          },
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreenView(),
      routes: {
        homeRoute: (context) => const HomePage(),
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        plateRoute: (context) => const LayoutView(),
        scanViewRoute: (context) => const ScanView(),
        plateListRoute: (context) => const PlateListView(),
        plateHistoryRoute: (context) => const PlateHistoryView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const LayoutView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const LoadingView();
        }
      },
    );
  }
}
