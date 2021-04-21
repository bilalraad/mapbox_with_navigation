import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:mapbox_api/mapbox_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';

///This fuction will return [LocationDetails] instance that has
///the name of the location you provided
Future<LocationDetails> requestlocationDetailsMapBox(LatLng loc) async {
  MapboxApi mapbox = MapboxApi(accessToken: DotEnv.env['MAPBOX_ACCESS_TOKEN']);

//[reverseGeocoding] means that you provide location and you get it's name
//[forwardGeocoding] is the opposite
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
    return LocationDetails(
      name: response.features[0].placeName,
      coordinates: loc,
    );
  }
  return null;
}
