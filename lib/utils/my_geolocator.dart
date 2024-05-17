import 'package:geolocator/geolocator.dart';

class MyGeolocator extends GeolocatorPlatform {
  static final MyGeolocator _singleton = MyGeolocator._internal();

  factory MyGeolocator() {
    return _singleton;
  }

  MyGeolocator._internal();

  Future<bool> get appSettingsOpened => openAppSettings();

  Future<LocationPermission> get permission => checkPermission();

  Future<bool> get locationSettingOpened => openLocationSettings();

  Future<bool> get isLocationEnabled => isLocationServiceEnabled();

  Stream<ServiceStatus> get serviceStatus => getServiceStatusStream();

  Future<LocationPermission> get requestedPermission => requestPermission();

  Stream<Position> getPosition([LocationSettings? locationSettings]) =>
      getPositionStream(locationSettings: locationSettings);
}
