import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:mapbox_api/mapbox_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:polyline/polyline.dart';

///Retrieve directions between waypoints. Peth requests must specify
///two waypoints as starting and ending points.
Future<List<LatLng>> requestpathfromMapBox(
    {@required LatLng from, @required LatLng to}) async {
  MapboxApi mapbox = MapboxApi(accessToken: DotEnv.env['MAPBOX_ACCESS_TOKEN']);

  DirectionsApiResponse response = await mapbox.directions.request(
    profile: NavigationProfile.DRIVING_TRAFFIC,
    overview: NavigationOverview.FULL,
    geometries: NavigationGeometries.POLYLINE6,
    steps: true,
    coordinates: <List<double>>[
      <double>[
        from.latitude,
        from.longitude,
      ],
      <double>[
        to.latitude,
        to.longitude,
      ],
    ],
  );
  print(response);
  if (response.error != null) {
    if (response.error is NavigationNoRouteError) {
      // handle NoRoute response
      print(response.error);
    } else if (response.error is NavigationNoSegmentError) {
      // handle NoSegment response
      print(response.error);
    }
    return null;
  }
  if (response.routes.isNotEmpty) {
    // Here we use Polyline to decode coordinates
    // with polylin ealgorithm
    //
    // see: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    final route = response.routes[0];
    final polyline = Polyline.Decode(
      encodedString: route.geometry as String,
      precision: 6,
    );
    final coordinates = polyline.decodedCoords;
    // this path will contains points
    // from Mapbox Direction API
    final path = <LatLng>[];
    for (var i = 0; i < coordinates.length; i++) {
      path.add(
        LatLng(
          coordinates[i][0],
          coordinates[i][1],
        ),
      );
    }
    return path;
  }
  return null;
}
