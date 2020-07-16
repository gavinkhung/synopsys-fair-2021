import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

final PermissionHandler _permissionHandler = PermissionHandler();

Future<loc.LocationData> getLocation() async {
  requestLocationPermission();
  loc.Location location = new loc.Location();

  bool _serviceEnabled;
  loc.PermissionStatus _permissionGranted;
  loc.LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {}
  }
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {}
  }

  return _locationData = await location.getLocation();
}

Future<bool> requestLocationPermission() async {
  return requestPermission(PermissionGroup.locationWhenInUse);
}

Future<bool> requestPermission(PermissionGroup permission) async {
  var result = await _permissionHandler.requestPermissions([permission]);
  if (result[permission] == PermissionStatus.granted) {
    return true;
  }
  return false;
}
