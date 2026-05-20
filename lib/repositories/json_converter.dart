import 'package:latlong2/latlong.dart';
import 'package:sua_vaga/models/parking_model.dart';

/// Converte o JSON bruto (como o que você enviou)
/// diretamente para ParkingLot usando seus modelos atuais.
ParkingLot parkingLotFromJson(Map<String, dynamic> json) {
  // ----- Location -----
  LatLng location = const LatLng(0, 0);
  if (json['location'] != null) {
    location = LatLng(
      (json['location']['lat'] ?? 0).toDouble(),
      (json['location']['lng'] ?? 0).toDouble(),
    );
  }

  // ----- Has floors? -----
  final hasFloors =
      json['floors'] != null && (json['floors'] as Map).isNotEmpty;

  // ----- Convert floors if they exist -----
  Map<String, ParkingFloor>? floors;
  if (hasFloors) {
    floors = (json['floors'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        ParkingFloor(
          label: value['label'] ?? key,
          layout: ParkingLayout.fromMap(value['layout']),
        ),
      ),
    );
  }

  // ----- Convert layout only if no floors -----
  ParkingLayout? layout;
  if (!hasFloors && json['layout'] != null) {
    layout = ParkingLayout.fromMap(json['layout']);
  }

  return ParkingLot(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    adress: json['adress'] ?? '',
    location: location,
    layout: layout,
    floors: floors,
  );
}
