import 'package:mapbox_gl/mapbox_gl.dart';

class LocationDetails {
  final String name;
  final LatLng coordinates;

  LocationDetails({this.name, this.coordinates});

  @override
  String toString() =>
      'LocationDetails(name: $name, coordinates: $coordinates)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    //when you compare two instances of LocationDetails it will
    //only compaire the coordinates
    return other is LocationDetails &&
        other.coordinates.latitude == coordinates.latitude &&
        other.coordinates.longitude == coordinates.longitude;
  }

  @override
  int get hashCode => name.hashCode ^ coordinates.hashCode;
}
