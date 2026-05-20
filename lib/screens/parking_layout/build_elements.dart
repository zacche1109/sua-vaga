import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sua_vaga/models/parking_model.dart';

Widget buildLayoutElement(LayoutElement element) {
  switch (element.type) {
    case 'arrow':
      return Transform.rotate(
        angle: (element.rotation ?? 0) * math.pi / 180,
        child: Icon(
          Icons.arrow_forward,
          size: element.size ?? 30,
          color: Colors.white,
        ),
      );
    case 'text':
      return Text(
        element.label ?? '',
        style: TextStyle(
          fontSize: element.size ?? 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    case 'leave':
      return Transform.rotate(
        angle: (element.rotation ?? 0) * math.pi / 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: element.size ?? 30, color: Colors.white),
            SizedBox(height: 4),
            Text(
              element.label ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: (element.size ?? 30) / 2.5,
              ),
            ),
          ],
        ),
      );
    case 'join':
      return Transform.rotate(
        angle: (element.rotation ?? 0) * math.pi / 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login, size: element.size ?? 30, color: Colors.white),
            SizedBox(height: 4),
            Text(
              element.label ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: (element.size ?? 30) / 2.5,
              ),
            ),
          ],
        ),
      );
    default:
      return SizedBox.shrink();
  }
}
