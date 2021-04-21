import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';
import 'package:mapbox_with_navigation/providers/mapProvider.dart';

//This widget should appear only when the mapState = MapState.ShowingPath
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

    ///This func will remove the path from the map and also it will check of the
    ///Starting/Destination(depending on ChangingLocationState) marker is not
    ///in your markers list or it's a user location marker
    ///then change its textField to 'Recently Viewed' it if neither of those is ture
    ///
    ///NOTE: Deleting the marker is not an option either, cuz the user maight
    ///decide to not change anything so it'll be hard to recover the removed marker
    void _checkIfMarkersIsNotPermanentAndClearPath(
        LatLng markerCoordinates, ChangingLocationState state) {
      mapController.clearLines();
      final tempSymbol = mapController.symbols.firstWhere(
          (symbol) => symbol.options.geometry == destLocation.coordinates);

      if (tempSymbol.options.textField == null ||
          (!tempSymbol.options.textField.contains('You') &&
              !tempSymbol.options.textField.contains('loc'))) {
        mapController.updateSymbol(
            tempSymbol,
            SymbolOptions(
                textField: 'Recently Viewed',
                textOffset: Offset(0, 2),
                iconImage: 'assets/icons/location_pin.png',
                textSize: 10));
      } else {
        mapController.updateSymbol(tempSymbol,
            SymbolOptions(iconImage: 'assets/icons/location_pin.png'));
      }

      context
          .read<MapProvider>()
          .changeMapstate(MapState.ChangingLocation, chnglocState: state);
    }

    return Positioned(
      bottom: 0,
      child: AnimatedOpacity(
          opacity: mapState == MapState.ShowingPath ? 1.0 : 0.0,
          duration: Duration(milliseconds: 600),
          child: mapState == MapState.ShowingPath
              ? Container(
                  padding: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.all(10.0),
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
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                _checkIfMarkersIsNotPermanentAndClearPath(
                                    startLocation.coordinates,
                                    ChangingLocationState.StartingLoc);
                              },
                              child: Text(
                                startLocation.name,
                                style: TextStyle(color: Colors.white),
                              ),
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
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                _checkIfMarkersIsNotPermanentAndClearPath(
                                    destLocation.coordinates,
                                    ChangingLocationState.EndingLoc);
                              },
                              child: Text(
                                destLocation.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))
              : Container()),
    );
  }
}
