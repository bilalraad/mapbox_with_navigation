import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:polyline/polyline.dart';
import 'package:location/location.dart';

enum SelectLocationType {
  None,
  FromLoc,
  ToLoc,
}

List<LatLng> markers = [
  LatLng(33.269487, 44.363137),
  LatLng(33.267123, 44.356938),
  LatLng(33.274968, 44.391772),
];

const String ACCESS_TOKEN =
    "pk.eyJ1IjoiYmlsYWxyYWQiLCJhIjoiY2ttYXp4MnhhMXg0NjJvbnhscm9qNHVyZSJ9.az1fKlaW3hGzqEPoU-76nA";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: FullMap(),
    );
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController mapController;
  LatLng fromLoc;
  LatLng toLoc;
  Line pathLine;
  Circle firstPoint;
  Circle secondPoint;
  SelectLocationType selectLocationType = SelectLocationType.None;
  LatLng userLocation;
  bool loading = false;
  Symbol tempMarker;
  Future<void> _onMapCreated(MapboxMapController controller) async {
    mapController = controller;
    Location location = Location();
    final _locationData = await location.getLocation();
    userLocation = LatLng(_locationData.latitude, _locationData.longitude);
    await mapController.addCircle(CircleOptions(geometry: userLocation));
    await mapController.addSymbol(SymbolOptions(
        geometry: userLocation, textField: 'you', textOffset: Offset(0, 1)));

    await mapController.animateCamera(CameraUpdate.newLatLng(userLocation));
    mapController.animateCamera(CameraUpdate.zoomTo(15));

    for (LatLng i in markers) {
      await mapController.addSymbol(SymbolOptions(
          geometry: i,
          iconImage: 'assets/icons/location_pin.png',
          iconSize: 0.5,
          textOffset: Offset(0, 2)));
    }

    mapController.onSymbolTapped.add((argument) async {
      if (tempMarker != null) {
        clearAll();
      }
      toLoc = argument.options.geometry;
      tempMarker = argument;
      mapController.updateSymbol(argument,
          SymbolOptions(iconImage: 'assets/icons/location_pin_red.png'));
      setState(() {});
    });
  }

  void _onMapLongClick(Point<double> point, LatLng coordinates) async {
    if (selectLocationType != SelectLocationType.None) {
      final point = await mapController.addCircle(
        CircleOptions(
            circleColor: "#5196F5", geometry: coordinates, draggable: true),
      );

      if (selectLocationType == SelectLocationType.FromLoc) {
        fromLoc = coordinates;
        firstPoint = point;
      } else {
        toLoc = coordinates;
        secondPoint = point;
      }
      setState(() {
        selectLocationType = SelectLocationType.None;
      });
    }
  }

  void clearAll() {
    mapController.clearLines();
    if (firstPoint != null) mapController.removeCircle(firstPoint);
    if (secondPoint != null) mapController.removeCircle(secondPoint);
    if (tempMarker != null)
      mapController.updateSymbol(tempMarker,
          SymbolOptions(iconImage: 'assets/icons/location_pin.png'));
    setState(() {
      pathLine = null;
      tempMarker = null;
      firstPoint = null;
      secondPoint = null;
      toLoc = null;
      fromLoc = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: Stack(
          children: [
            MapboxMap(
              accessToken: ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              onMapLongClick: _onMapLongClick,
              zoomGesturesEnabled: true,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(33.2232, 43.6793), zoom: 10),
              onStyleLoadedCallback: onStyleLoadedCallback,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              child: selectLocationType == SelectLocationType.None
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: fromLoc != null || loading == true
                                    ? null
                                    : () {
                                        setState(() {
                                          selectLocationType =
                                              SelectLocationType.FromLoc;
                                        });
                                      },
                                child: Text('Select starting point')),
                            Spacer(),
                            ElevatedButton(
                                onPressed: toLoc != null || loading == true
                                    ? null
                                    : () async {
                                        setState(() {
                                          selectLocationType =
                                              SelectLocationType.ToLoc;
                                        });
                                      },
                                child: Text('Select destination')),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                onPressed: fromLoc == null || toLoc == null
                                    ? null
                                    : () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        if (fromLoc != null && toLoc != null) {
                                          final path =
                                              await _requestpathfromMapBox(
                                                  fromLoc, toLoc);

                                          if (path.length > 0) {
                                            pathLine =
                                                await mapController.addLine(
                                              LineOptions(
                                                geometry: path,
                                                lineColor: "#8196F5",
                                                lineWidth: 3.0,
                                                lineOpacity: 1,
                                                draggable: false,
                                              ),
                                            );
                                          }
                                          setState(() {
                                            loading = false;
                                          });
                                        }
                                      },
                                child: Text('show path')),
                            ElevatedButton(
                                onPressed: clearAll, child: Text('Clear All')),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Long press to select the location',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectLocationType =
                                        SelectLocationType.None;
                                  });
                                },
                                child: Text('Cancle')),
                            if (selectLocationType ==
                                    SelectLocationType.FromLoc &&
                                userLocation != null)
                              ElevatedButton(
                                  onPressed: () async {
                                    firstPoint = await mapController.addCircle(
                                      CircleOptions(
                                        circleColor: "#5196F5",
                                        geometry: userLocation,
                                      ),
                                    );
                                    setState(() {
                                      selectLocationType =
                                          SelectLocationType.None;
                                      fromLoc = userLocation;
                                    });
                                  },
                                  child: Text('Select My location')),
                          ],
                        ),
                      ],
                    ),
            ),
            if (toLoc != null)
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                          icon: Icon(Icons.directions),
                          onPressed: () async {
                            firstPoint = await mapController.addCircle(
                              CircleOptions(
                                circleColor: "#5196F5",
                                geometry: userLocation,
                              ),
                            );
                            setState(() {
                              fromLoc = userLocation;
                            });

                            final path =
                                await _requestpathfromMapBox(fromLoc, toLoc);

                            if (path.length > 0) {
                              pathLine = await mapController.addLine(
                                LineOptions(
                                  geometry: path,
                                  lineColor: "#8196F5",
                                  lineWidth: 3.0,
                                  lineOpacity: 1,
                                  draggable: false,
                                ),
                              );
                            }
                          },
                          label: Text('Directions to the marker')),
                      ElevatedButton(
                          onPressed: clearAll, child: Text('Cancel')),
                      if (loading == true)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              )
          ],
        ));
  }

  void onStyleLoadedCallback() {}
}

Future<List<LatLng>> _requestpathfromMapBox(LatLng from, LatLng to) async {
  MapboxApi mapbox = MapboxApi(accessToken: ACCESS_TOKEN);

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
  if (response.error != null) {
    if (response.error is NavigationNoRouteError) {
      // handle NoRoute response
    } else if (response.error is NavigationNoSegmentError) {
      // handle NoSegment response
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
