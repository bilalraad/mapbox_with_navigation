import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

enum MapState {
  None,
  Pinlocation,
  ShowingPath,
  ChangingLocation,
}

///This will help to identify whitch location the user is currently changing
enum ChangingLocationState { StartingLoc, EndingLoc }

class MapProvider extends ChangeNotifier {
  MapboxMapController _mapController;
  MapState _mapState = MapState.None;
  ChangingLocationState _changingLocState;

  MapState get mapState => _mapState;
  MapboxMapController get mapController => _mapController;
  ChangingLocationState get changLocState => _changingLocState;

  ///we you change the mapstate to MapState.ChangingLocation you should provide
  ///[ChangingLocationState] other that that just leave it
  void changeMapstate(MapState newState, {ChangingLocationState chnglocState}) {
    _mapState = newState;
    if (_mapState == MapState.ChangingLocation) {
      _changingLocState = chnglocState;
    }
    notifyListeners();
  }

  ///this function should be used only one time
  ///taht is when [_onMapCreated] is called
  MapboxMapController setController(MapboxMapController controller) {
    _mapController = controller;
    notifyListeners();
    return _mapController;
  }
}
