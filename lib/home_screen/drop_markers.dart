import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropMarker {
  final String name;
  final LatLng position;

  DropMarker(this.name, this.position);
}

class DropMarkers {
  static List<DropMarker> dropMarkers = [];
}