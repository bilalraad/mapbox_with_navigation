import 'package:mapbox_api/mapbox_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/main.dart';

Future<String> requestlocationDetailsMapBox(LatLng loc) async {
  MapboxApi mapbox = MapboxApi(accessToken: ACCESS_TOKEN);

  final response = await mapbox.reverseGeocoding.request(
    coordinate: <double>[
      loc.latitude,
      loc.longitude,
    ],
    language: 'en',
  );

  if (response.error != null) {
    if (response.error is GeocoderError) {
      print('GeocoderError: ${(response.error as GeocoderError).message}');
      return null;
    }

    print('Network error');
    return null;
  }

  if (response.features != null && response.features.isNotEmpty) {
    return response.features[0].placeName;
  }
  return null;
}
