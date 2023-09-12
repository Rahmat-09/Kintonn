import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/helpers/MaterialColor.dart';
import 'package:untitled/ui/LayoutNavigationBar.dart';
import 'package:untitled/ui/LoginPage.dart';

import 'firebase_options.dart';
import 'helpers/HexColor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dynamic token = await SessionManager().get("token");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };


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
