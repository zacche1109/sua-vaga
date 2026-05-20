import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sua_vaga/models/parking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class ParkingRepository {
  //ADD

  final CollectionReference _parkingLotsCollection = FirebaseFirestore.instance
      .collection('parkingLots');

  Future<void> addParkingLot(ParkingLot lot) async {
    try {
      final map = lot.toMap();
      log("Enviando para o Firestore: $map");
      await _parkingLotsCollection.doc(lot.id).set(map);
    } catch (e) {
      log('Erro ao adicionar estacionamento: $e');
    }
  }

  //SELECT ALL

  Future<List<ParkingLot>> getAllParkingLots() async {
    //pega coleção de parkingLots do firestore e percorre lot por lot retransformando no formato da classe ParkingLot
    final parkingLots = await _parkingLotsCollection.get();
    return parkingLots.docs.map((lot) {
      final data = lot.data() as Map<String, dynamic>;
      return ParkingLot.fromMap(data);
    }).toList();
  }

  //UPDATE

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateParking(
    String parkingId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _firestore
          .collection('parkingLots')
          .doc(parkingId)
          .update(updatedData);
      log('Estacionamento atualizado com sucesso.');
    } catch (e) {
      log('Erro ao atualizar estacionamento: $e');
      rethrow;
    }
  }

  //DELETE

  Future<void> deleteParking(String id) async {
    await _firestore.collection('parkingLots').doc(id).delete();
  }

  //GET BY ID

  Future<DocumentSnapshot> getParkingById(String id) async {
    return await _firestore.collection('parkingLots').doc(id).get();
  }
}

//função de geração de JSON

Future<void> jsonGenerate() async {
  final List<ParkingLot> lots = await ParkingRepository().getAllParkingLots();
  final List<Map<String, dynamic>> jsonLots =
      lots.map((lot) => lot.toMap()).toList();
  final String jsonString = jsonEncode(jsonLots);
  debugPrint(jsonString);
}

// SAVE e LOAD de favoritos

//login anônimo, sem precisar de tala de login, apenas para identificar diferentes instalações podendo salvar os favoritos de cada instalação
Future<void> signInAnonymously() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
    log("Usuário autenticado anonimamente.");
  } else {
    log("Usuário já autenticado: ${auth.currentUser!.uid}");
  }
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final String userId = FirebaseAuth.instance.currentUser!.uid;

Future<void> toggleFavorite(String parkingLotId, bool isFavorite) async {
  final docRef = firestore
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(parkingLotId);

  if (isFavorite) {
    //marca o horario q setou o favorite
    await docRef.set({'timestamp': FieldValue.serverTimestamp()});
  } else {
    await docRef.delete();
  }
}
