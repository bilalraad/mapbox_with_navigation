import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mapProvider.dart';

//This widget should appear only when the mapState = MapState.ChangingLocation
class ChangingLocation extends StatelessWidget {
  final Function setNewLoc;

  const ChangingLocation({@required this.setNewLoc});

  @override
  Widget build(BuildContext context) {
    final mapState = context.watch<MapProvider>().mapState;

    bool isStarting = context.read<MapProvider>().changLocState ==
        ChangingLocationState.StartingLoc;
    return Positioned(
      bottom: 0,
      child: AnimatedOpacity(
        opacity: mapState == MapState.ChangingLocation ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600),
        child: mapState == MapState.ChangingLocation
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          isStarting
                              ? 'Select Starting location'
                              : 'Select Ending location ',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          'Long press to select the Location',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )
                      ],
                    ),
                    OutlinedButton(
                      onPressed: setNewLoc,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).accentColor,
                      ),
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }
}
