import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_with_navigation/providers/mapProvider.dart';

class ChangingLocation extends StatelessWidget {
  final Function setNewLoc;

  const ChangingLocation({Key key, this.setNewLoc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>().mapState;

    bool isStarting = context.read<MapProvider>().changLocState ==
        ChangingLocationState.StartingLoc;
    return AnimatedOpacity(
        opacity: mapState == MapState.ChangingLocation ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600),
        child: mapState == MapState.ChangingLocation
            ? Container(
                width: double.infinity,
                height: 100,
                color: Colors.pink,
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isStarting
                          ? 'select Starting location \nLong press to select the Location'
                          : 'select Ending location \nLong press to select the Location',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    OutlinedButton(
                      onPressed: setNewLoc,
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : Container());
  }
}
