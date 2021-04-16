import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

enum MapState {
  None,
  Pinlocation,
  ShowingPath,
  ChangingLocation,
}
enum ChangingLocationState { StartingLoc, EndingLoc }

class MapProvider extends ChangeNotifier {
  MapboxMapController _mapController;
  MapState _mapState = MapState.None;
  ChangingLocationState _changingLocState;

  MapState get mapState => _mapState;
  MapboxMapController get mapController => _mapController;
  ChangingLocationState get changLocState => _changingLocState;

  void changeMapstate(MapState newState, {ChangingLocationState chnglocState}) {
    _mapState = newState;
    if (_mapState == MapState.ChangingLocation) {
      _changingLocState = chnglocState;
    }
    notifyListeners();
  }

  MapboxMapController setController(MapboxMapController controller) {
    _mapController = controller;
    notifyListeners();
    return _mapController;
  }
}
