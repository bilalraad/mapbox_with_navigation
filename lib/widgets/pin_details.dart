import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_with_navigation/utils/get_location_details.dart';

class PinDetails extends StatelessWidget {
  final MapboxMapController mapController;
  final LatLng pinlocation;
  final Function showPath;
  const PinDetails({
    this.mapController,
    this.pinlocation,
    this.showPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: 120,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: requestlocationDetailsMapBox(pinlocation),
            initialData: '${pinlocation.latitude}, ${pinlocation.longitude}',
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator.adaptive()
                  : Text(
                      snapshot.data,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    );
            },
          ),
          Spacer(),
          ElevatedButton.icon(
              icon: Icon(Icons.directions),
              onPressed: showPath,
              label: Text('Directions')),
        ],
      ),
    );
  }
}
