import 'package:flutter/material.dart';
import 'package:mapbox_with_navigation/model/location_details.dart';

class PathWidget extends StatelessWidget {
  final LocationDetails userLocation;
  final LocationDetails destLocation;
  const PathWidget({
    @required this.userLocation,
    @required this.destLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    onPressed: () {},
                    child: Text(userLocation.name ?? 'Select starting point'),
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
                    onPressed: () async {},
                    child: Text(destLocation.name ?? 'Select destination'),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
