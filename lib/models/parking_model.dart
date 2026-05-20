import 'package:sua_vaga/models/spot_model.dart';
import 'package:latlong2/latlong.dart';

class ParkingLot {
  final String id;
  final String name;
  final LatLng location;
  final String adress;
  final ParkingLayout? layout;
  final Map<String, ParkingFloor>? floors;

  ParkingLot({
    required this.id,
    required this.name,
    required this.location,
    required this.adress,
    this.layout,
    this.floors,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'adress': adress,
      if (floors == null || floors!.isEmpty) 'layout': layout?.toMap(),
      if (floors != null)
        'floors': floors!.map((key, floor) => MapEntry(key, floor.toMap())),
    };
  }

  factory ParkingLot.fromMap(Map<String, dynamic> map) {
    final floorsData = map['floors'];
    final hasFloors = floorsData != null && (floorsData as Map).isNotEmpty;

    return ParkingLot(
      id: map['id'],
      name: map['name'],
      location: LatLng(map['location']['lat'], map['location']['lng']),
      adress: map['adress'],
      layout:
          !hasFloors
              ? (map['layout'] != null
                  ? ParkingLayout.fromMap(map['layout'])
                  : null)
              : null,
      floors:
          hasFloors
              ? (map['floors'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, ParkingFloor.fromMap(value)),
              )
              : null,
    );
  }
}

class ParkingLayout {
  final double width;
  final double height;
  final Map<String, LayoutElement> elements;
  final Map<String, Spot> spots;

  ParkingLayout({
    required this.width,
    required this.height,
    required this.elements,
    required this.spots,
  });

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'elements': elements.map((key, value) => MapEntry(key, value.toMap())),
      'spots': spots.map((key, spot) => MapEntry(key, spot.toMap())),
    };
  }

  factory ParkingLayout.fromMap(Map<String, dynamic> map) {
    return ParkingLayout(
      width: (map['width'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      elements: Map<String, LayoutElement>.from(
        (map['elements'] ?? {}).map(
          (key, value) => MapEntry(
            key.toString(),
            LayoutElement.fromMap(value as Map<String, dynamic>),
          ),
        ),
      ),
      spots: Map<String, Spot>.from(
        (map['spots'] ?? {}).map(
          (key, value) => MapEntry(
            key.toString(),
            Spot.fromMap(value as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }
}

class LayoutElement {
  final String type;
  final double x;
  final double y;
  final double? rotation;
  final String? label;
  final double? size;

  LayoutElement({
    required this.type,
    required this.x,
    required this.y,
    this.rotation,
    this.label,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'x': x,
      'y': y,
      if (rotation != null) 'rotation': rotation,
      if (label != null) 'label': label,
      if (size != null) 'fontSize': size,
    };
  }

  factory LayoutElement.fromMap(Map<String, dynamic> map) {
    return LayoutElement(
      type: map['type'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      rotation:
          map['rotation'] != null ? (map['rotation'] as num).toDouble() : null,
      label: map['label'],
      size:
          map['fontSize'] != null ? (map['fontSize'] as num).toDouble() : null,
    );
  }
}

class ParkingFloor {
  final String label;
  final ParkingLayout layout;

  ParkingFloor({required this.label, required this.layout});

  Map<String, dynamic> toMap() {
    return {'label': label, 'layout': layout.toMap()};
  }

  factory ParkingFloor.fromMap(Map<String, dynamic> map) {
    return ParkingFloor(
      label: map['label'] ?? '',
      layout: ParkingLayout.fromMap(map['layout'] ?? {}),
    );
  }
}
