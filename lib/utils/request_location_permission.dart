import 'package:location/location.dart';

///Asking for location Permission and if granted it will return the user location
///if not it'll return [null]!!
Future<LocationData> requestLicationPermissionAndUserLoc() async {
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  try {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    final _locationData = await location.getLocation();
    print('object');
    return _locationData;
  } catch (e) {
    print(e);
  }
  return null;
}
