import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sua_vaga/common/colors.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      //pushReplacement usa apra substituir a tela atual sem permitir que o usuário volte
      Navigator.pushReplacement(
        context, //Navigator é nativo do flutter para navegar entre telas
        MaterialPageRoute(
          builder: (context) => HomeScreen(), //página q vai susbstituir
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkBlue,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Image.asset("assets/logo.png"),
      ),
    );
  }
}
