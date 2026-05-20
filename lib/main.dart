import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sua_vaga/repositories/parking_repository.dart';
//import 'package:sua_vaga/repositories/parking_utils.dart';
import 'package:sua_vaga/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sua_vaga/theme_notifier.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await signInAnonymously();
  //await insertParkingLot();
  //await updateSpots();
  //await update();
  //await updateElement();
  //await updateMultipleArrows();
  debugPrintGestureArenaDiagnostics = false;
  debugPaintSizeEnabled = false;
  //bloquear uso de celular no modo paisagem, permitir apenas modo retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

final themeNotifier = ThemeNotifier();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      //se baseia no valor do themeNotifier, q é adquirido na tela de opções
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          //define as cores padrões para determina tema em especifico
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
          ),
          themeMode: currentTheme,
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
