import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';
import 'package:mapbox_with_navigation/widgets/path_widget.dart';

import 'package:mapbox_with_navigation/utils/navigate_to_user_location.dart';
import 'package:mapbox_with_navigation/utils/request_path.dart';
import 'package:mapbox_with_navigation/widgets/pin_details.dart';

enum MapState {
  None,
  Pinlocation,
  ShowingPath,
}

List<LatLng> markers = [
  LatLng(33.269487, 44.363137),
  LatLng(33.267123, 44.356938),
  LatLng(33.274968, 44.391772),
];

const String ACCESS_TOKEN =
    "pk.eyJ1IjoiYmlsYWxyYWQiLCJhIjoiY2ttYXp4MnhhMXg0NjJvbnhscm9qNHVyZSJ9.az1fKlaW3hGzqEPoU-76nA";
void main() {
  // WidgetsFlutterBinding.ensureInitialized();

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
  MapState mapState = MapState.None;
  LatLng userLocation;
  bool loading = false;
  Symbol selectedMarker;

  Future<void> _onMapCreated(MapboxMapController controller) async {
    mapController = controller;
    userLocation = await navigateToUserLocation(controller);

    for (LatLng i in markers) {
      await mapController.addSymbol(
        SymbolOptions(
          geometry: i,
          iconImage: 'assets/icons/location_pin.png',
          iconSize: 0.5,
          textOffset: Offset(0, 1),
        ),
      );
    }
    mapController.onSymbolTapped.add((marker) async {
      if (marker.options.geometry != userLocation) {
        if (selectedMarker != null) {
          clearAll();
        }
        toLoc = marker.options.geometry;
        selectedMarker = marker;
        mapController.updateSymbol(
          marker,
          SymbolOptions(iconImage: 'assets/icons/location_pin_red.png'),
        );
        setState(() {
          mapState = MapState.Pinlocation;
        });
      }
    });
  }

  void _onMapLongClick(Point<double> point, LatLng coordinates) async {
    if (mapState == MapState.None) {
      selectedMarker = await mapController.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          iconImage: 'assets/icons/location_pin.png',
          iconSize: 0.5,
          draggable: true,
        ),
      );
      toLoc = coordinates;
    }
    setState(() {
      mapState = MapState.Pinlocation;
    });
  }

  void clearAll() {
    mapController.clearLines();
    if (firstPoint != null) mapController.removeSymbol(selectedMarker);
    if (selectedMarker != null)
      mapController.updateSymbol(selectedMarker,
          SymbolOptions(iconImage: 'assets/icons/location_pin.png'));
    setState(() {
      pathLine = null;
      selectedMarker = null;
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
          leading: mapState != MapState.None
              ? TextButton(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    clearAll();
                    setState(() {
                      mapState = MapState.None;
                    });
                  },
                )
              : null,
        ),
        body: Stack(
          children: [
            MapboxMap(
              accessToken: ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              onMapLongClick: _onMapLongClick,
              onMapClick: (point, coordinates) {
                if (mapState != MapState.ShowingPath) {
                  setState(() {
                    mapState = MapState.None;
                  });
                  clearAll();
                }
              },
              zoomGesturesEnabled: true,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(33.3152, 44.3661), zoom: 10),
            ),
            if (mapState == MapState.ShowingPath)
              PathWidget(
                userLocation: LocationDetails(
                    coordinates: userLocation, name: 'your locaion'),
                destLocation: LocationDetails(
                    coordinates: selectedMarker.options.geometry,
                    name: 'random location'),
              ),
            if (mapState == MapState.Pinlocation)
              Positioned(
                  bottom: 0,
                  child: PinDetails(
                    mapController: mapController,
                    pinlocation: selectedMarker.options.geometry,
                    showPath: showPath,
                  ))
          ],
        ));
  }

  Future<void> showPath() async {
    final path = await requestpathfromMapBox(
        from: userLocation, to: selectedMarker.options.geometry);

    if (path.length > 0) {
      await mapController.addLine(
        LineOptions(
          geometry: path,
          lineColor: "#8196F5",
          lineWidth: 3.0,
          lineOpacity: 1,
          draggable: false,
        ),
      );
      setState(() {
        mapState = MapState.ShowingPath;
      });
    }
  }
}
