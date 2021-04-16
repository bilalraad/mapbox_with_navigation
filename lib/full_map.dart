import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:provider/provider.dart';

import './utils/navigate_to_user_location.dart';
import './utils/add_markers_to_map.dart';
import './model/location_details.dart';
import './providers/mapProvider.dart';
import './widgets/pin_details.dart';
import './widgets/path_widget.dart';
import './utils/request_path.dart';
import './widgets/change_loc.dart';

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController mapController;
  MapState mapState;
  LatLng userLocation;
  // bool loading = false;
  Symbol selectedMarker;
  LocationDetails _startLocation;
  LocationDetails _destLocation;

  Future<void> _onMapCreated(MapboxMapController controller) async {
    mapController = context.read<MapProvider>().setController(controller);
    userLocation = await navigateToUserLocation(mapController);
    addYourMarkersToTheMap(mapController);

    mapController.onSymbolTapped.add((marker) async {
      if (marker.options.geometry != userLocation) {
        if (selectedMarker != null) {
          clearAll();
        }
        selectedMarker = marker;
        mapController.updateSymbol(
          marker,
          SymbolOptions(iconImage: 'assets/icons/location_pin_red.png'),
        );
        context.read<MapProvider>().changeMapstate(MapState.Pinlocation);
      }
    });
  }

  void _onMapLongClick(Point<double> point, LatLng coordinates) async {
    if (mapState == MapState.None || mapState == MapState.ChangingLocation) {
      selectedMarker = await mapController.addSymbol(
        SymbolOptions(
          geometry: coordinates,
          iconImage: 'assets/icons/location_pin.png',
          iconSize: 0.5,
          draggable: true,
        ),
      );
    }
    if (mapState != MapState.ChangingLocation)
      context.read<MapProvider>().changeMapstate(MapState.Pinlocation);
  }

  @override
  Widget build(BuildContext context) {
    mapState = context.watch<MapProvider>().mapState;
    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
          elevation: 0,
          leading: mapState != MapState.None
              ? TextButton(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (mapState != MapState.ChangingLocation)
                      clearAll();
                    else
                      showPath(_destLocation);
                  },
                )
              : null,
        ),
        body: Stack(
          children: [
            MapboxMap(
              accessToken: DotEnv.env['MAPBOX_ACCESS_TOKEN'],
              onMapCreated: _onMapCreated,
              onMapLongClick: _onMapLongClick,
              onMapClick: (point, coordinates) {
                if (mapState != MapState.ShowingPath) {
                  clearAll();
                }
              },
              zoomGesturesEnabled: true,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(33.3152, 44.3661), zoom: 10.0),
            ),
            PathWidget(
              startLocation: _startLocation,
              destLocation: _destLocation,
            ),
            ChangingLocation(
              setNewLoc: setNewLoc,
            ),
            PinDetails(
              marker: selectedMarker,
              showPath: showPath,
            )
          ],
        ));
  }

  void setNewLoc() {
    final temploc = LocationDetails(
      coordinates: selectedMarker.options.geometry,
      name: selectedMarker.options.textField ?? "Droped pin",
    );
    if (context.read<MapProvider>().changLocState ==
        ChangingLocationState.StartingLoc) {
      _startLocation = temploc;
    } else {
      _destLocation = temploc;
    }

    showPath(_destLocation, startLocation: _startLocation);
  }

  Future<void> showPath(
    LocationDetails destLocation, {
    LocationDetails startLocation,
  }) async {
    _destLocation = destLocation;

    if (startLocation != null) {
      _startLocation = startLocation;
    } else {
      _startLocation = userLocation != null
          ? LocationDetails(coordinates: userLocation, name: 'my location')
          : LocationDetails(coordinates: null, name: 'select start location');
    }
    context.read<MapProvider>().changeMapstate(MapState.ShowingPath);
    if (_destLocation != null && _startLocation != null) {
      final path = await requestpathfromMapBox(
          from: _startLocation.coordinates, to: _destLocation.coordinates);
      if (path.length > 0) {
        await mapController.addLine(
          LineOptions(
            geometry: path,
            lineColor: "#8196F5",
            lineWidth: 4.0,
            lineOpacity: 1.0,
          ),
        );
      }
    }
  }

  Future<void> clearAll() async {
    mapController.clearLines();

    if (selectedMarker.options.textField == null ||
        !selectedMarker.options.textField.contains('loc'))
      await mapController.removeSymbol(selectedMarker);
    else
      mapController.updateSymbol(selectedMarker,
          SymbolOptions(iconImage: 'assets/icons/location_pin.png'));
    context.read<MapProvider>().changeMapstate(MapState.None);
    selectedMarker = null;
  }
}
