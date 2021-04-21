import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';
import 'package:mapbox_with_navigation/providers/mapProvider.dart';
import 'package:mapbox_with_navigation/utils/get_location_details.dart';
import 'package:provider/provider.dart';

class PinDetails extends StatelessWidget {
  final Symbol marker;
  final Function(LocationDetails) showPath;

  const PinDetails({
    this.marker,
    this.showPath,
  });

  @override
  Widget build(BuildContext context) {
    final pinlocation = marker != null ? marker.options.geometry : null;
    final mapState = context.watch<MapProvider>().mapState;
    LocationDetails destDetails;
    return Positioned(
      bottom: 0,
      child: AnimatedOpacity(
        opacity: mapState == MapState.Pinlocation ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600),
        child: mapState == MapState.Pinlocation
            ? Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 120,
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<LocationDetails>(
                      future: requestlocationDetailsMapBox(pinlocation),
                      initialData:
                          LocationDetails(coordinates: pinlocation, name: ''),
                      builder:
                          (context, AsyncSnapshot<LocationDetails> snapshot) {
                        destDetails = marker.options.textField != null
                            ? LocationDetails(
                                coordinates: pinlocation,
                                name:
                                    '${marker.options.textField} | ${snapshot.data.name}')
                            : snapshot.data;
                        return Flexible(
                          flex: 1,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 40,
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    //the output will be marker name(if there's any) | the requested location name(i.e. baghdad jadriyah)
                                    destDetails.name,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator.adaptive())
                                  : Container(),
                            ],
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      icon: Icon(Icons.directions),
                      onPressed: () => showPath(destDetails),
                      label: Text('Directions'),
                    ),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }
}
