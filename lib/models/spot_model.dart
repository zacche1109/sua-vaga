import 'package:cloud_firestore/cloud_firestore.dart';

class Spot {
  final String id;
  bool status;
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double? rotation;
  //serve para atualizar em tempo real com o protótipo
  final DocumentReference? reference;

  Spot({
    required this.id,
    required this.status,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation,
    this.reference,
  });

  factory Spot.fromMap(
    Map<String, dynamic> map, {
    DocumentReference? reference,
  }) {
    return Spot(
      id: map['id'] ?? '',
      status: map['status'] ?? false,
      type: map['type'] ?? 'carro',
      x: (map['x'] ?? 0).toDouble(),
      y: (map['y'] ?? 0).toDouble(),
      width: (map['width'] ?? 50).toDouble(),
      height: (map['height'] ?? 30).toDouble(),
      rotation:
          map['rotation'] != null ? (map['rotation'] as num).toDouble() : null,
      reference: reference,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'status': status,
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    if (rotation != null) {
      map['rotation'] = rotation!;
    }
    return map;
  }

  void toggleStatus() {
    status = !status;

    //preciso fazer um adon para caso tenha floor

    // Atualiza também no Firebase
    if (reference != null) {
      //pega referencia e splita ela em 2, exemplo parkingLot/3 vira um array com []'parkingLot', 3]
      final pathParts = reference!.path.split('/');
      //tratamento de erro, tem q ter duas partes
      if (pathParts.length >= 2) {
        //pega o id
        final parkingLotId = pathParts[1];
        //atualiza o caminho certinho do status
        FirebaseFirestore.instance
            .collection('parkingLots')
            .doc(parkingLotId)
            .update({'layout.spots.$id.status': status});
      }
    }
  }
}
