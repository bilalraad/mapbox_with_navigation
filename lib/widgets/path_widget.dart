import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';
import 'package:mapbox_with_navigation/providers/mapProvider.dart';

class PathWidget extends StatelessWidget {
  final LocationDetails startLocation;
  final LocationDetails destLocation;
  const PathWidget({
    @required this.startLocation,
    @required this.destLocation,
  });

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>().mapState;
    final mapController = context.watch<MapProvider>().mapController;

    void _checkIfMarkersIsNotPermanentAndClearPath(
        LatLng markerCoordinates, ChangingLocationState state) {
      mapController.clearLines();
      final tempSymbol = mapController.symbols.firstWhere(
          (symbol) => symbol.options.geometry == destLocation.coordinates);
      if (tempSymbol.options.textField == null ||
          (!tempSymbol.options.textField.contains('You') &&
              !tempSymbol.options.textField.contains('loc')))
        mapController.removeSymbol(tempSymbol);

      context
          .read<MapProvider>()
          .changeMapstate(MapState.ChangingLocation, chnglocState: state);
    }

    return AnimatedOpacity(
        opacity: mapState == MapState.ShowingPath ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600),
        child: mapState == MapState.ShowingPath
            ? Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.20,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.my_location),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: OutlinedButton(
                            onPressed: () {
                              _checkIfMarkersIsNotPermanentAndClearPath(
                                  startLocation.coordinates,
                                  ChangingLocationState.StartingLoc);
                            },
                            child: Text(startLocation.name),
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_downward_sharp),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.location_on),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: OutlinedButton(
                            onPressed: () async {
                              _checkIfMarkersIsNotPermanentAndClearPath(
                                  destLocation.coordinates,
                                  ChangingLocationState.EndingLoc);
                            },
                            child: Text(destLocation.name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
            : Container());
  }
}
