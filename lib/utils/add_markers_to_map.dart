import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';

List<LocationDetails> markers = [
  LocationDetails(coordinates: LatLng(33.269487, 44.363137), name: 'loc #1'),
  LocationDetails(coordinates: LatLng(33.267123, 44.356938), name: 'loc #2'),
  LocationDetails(coordinates: LatLng(33.274968, 44.391772), name: 'loc #3'),
];

Future<void> addYourMarkersToMap(MapboxMapController mapController) async {
  for (var marker in markers) {
    try {
      //for some reason the mapController is null for a
      //few milliseconds even if the map fully loaded
      //so I added thes quick fix
      await Future.delayed(Duration(seconds: 1));
      await mapController.addSymbol(
        SymbolOptions(
          geometry: marker.coordinates,
          textField: marker.name,
          iconImage: 'assets/icons/location_pin.png',
          iconSize: 0.5,
          textOffset: Offset(0.0, 1.0),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
