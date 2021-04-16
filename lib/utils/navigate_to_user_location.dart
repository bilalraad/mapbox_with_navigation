import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/utils/request_location_permission.dart';

Future<LatLng> navigateToUserLocation(MapboxMapController mapController) async {
  final userLocation = await requestLicationPermissionandUserLoc();
  final _defaultLocation = LatLng(33.3152, 44.3661);
  if (userLocation != null) {
    mapController.requestMyLocationLatLng();
    await mapController.addSymbol(
      SymbolOptions(
        geometry: userLocation,
        textField: 'You',
        textOffset: Offset(0, 2),
        iconImage: 'assets/icons/location_pin.png',
        iconSize: 0.5,
      ),
    );
  }
  await mapController.animateCamera(
      CameraUpdate.newLatLngZoom(userLocation ?? _defaultLocation, 15));

  return userLocation;
}
