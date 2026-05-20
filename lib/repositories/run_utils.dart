import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:sua_vaga/repositories/parking_repository.dart';
import 'package:sua_vaga/repositories/parking_utils.dart';
import 'dart:developer';
import 'package:sua_vaga/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //await jsonGenerate();
  //await insertParkingLot();
  await insertSpecificParkingLot();

  log('Atualização concluída.');
}
