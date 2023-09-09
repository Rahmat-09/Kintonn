import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/helpers/MaterialColor.dart';
import 'package:untitled/ui/LayoutNavigationBar.dart';
import 'package:untitled/ui/LoginPage.dart';

import 'helpers/HexColor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dynamic token = await SessionManager().get("token");
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBql1eGH2AqCPARMkM4sgmKSjfWKYT-es4",
          appId: "1:459643024950:web:29467854b4481f4e5b8a97",
          messagingSenderId: "459643024950",
          projectId: "kinton-82dc9"));

  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: buildMaterialColor(HexColor("#ef9904")),
      fontFamily: GoogleFonts.poppins().fontFamily,
      primaryColor: HexColor("#ef9904"),
    ),
    debugShowCheckedModeBanner: false,
    home: token != null ? LayoutNavigationBar(accesstoken: token.toString()) : const MyApp(),
    routes: {
      'register': (context) => const LoginPage(),
      'login': (context) => const LoginPage(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
