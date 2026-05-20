import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sua_vaga/models/parking_model.dart';
import 'package:sua_vaga/screens/parking_layout/parking_layout_screen.dart';

class ParkingStreamBuilder extends StatefulWidget {
  final ParkingLot initialParkingLot;

  const ParkingStreamBuilder({super.key, required this.initialParkingLot});

  @override
  State<ParkingStreamBuilder> createState() => _ParkingStreamBuilderState();
}

class _ParkingStreamBuilderState extends State<ParkingStreamBuilder> {
  late Stream<DocumentSnapshot> _parkingStream;

  @override
  void initState() {
    super.initState();
    //.snapshots funciona como lsitener, ele escuta qqrl mudança no firestore
    _parkingStream =
        FirebaseFirestore.instance
            .collection('parkingLots')
            .doc(widget.initialParkingLot.id)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      //aqui vc faz o stream builder estar diretamente relacionado com o listener
      //ent a stream (que é sinonimo de listener) faz oa acionamento do stream builder toda vez q detecta mudança
      stream: _parkingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Erro: ${snapshot.error}')));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text('Estacionamento não encontrado')),
          );
        }

        // Converte o snapshot para um ParkingLot atualizado
        final updatedParkingLot = ParkingLot.fromMap({
          ...snapshot.data!.data() as Map<String, dynamic>,
          'id': widget.initialParkingLot.id,
        });
        //reload da layotuScreen com o novo parkingLot atualizado
        return ParkingLayoutScreen(parkingLot: updatedParkingLot);
      },
    );
  }
}
