import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../css/assets.dart';
import '../css/css.dart';
import '../css/measurements.dart';
import '../css/shades.dart';
import '../extensions/extensions.dart';
import '../models/common/app_config.dart';
import '../models/common/progress.dart';
import '../states/common_state.dart';
import 'enums.dart';
import 'methods.dart';
import 'my_geocoder.dart';
import 'my_geolocator.dart';
import 'my_local_authentication.dart';
import 'route_generator.dart';

int page = 0;

WidgetsBinding? wb;

bool hideText = true;

GlobalConfiguration? gc;

AppConfig acf = AppConfig();

DateTime? currentBackPressTime;

StreamSubscription<Progress>? ssc;

Map<String, dynamic> body = <String, dynamic>{};

const apiMode =
    kDebugMode ? APIMode.dev : (kProfileMode ? APIMode.test : APIMode.prod);

final css = Css(),
    st = Stopwatch(),
    assets = Assets(),
    shades = Shades(),
    gco = MyGeocoder(),
    gl = MyGeolocator(),
    conn = Connectivity(),
    picker = ImagePicker(),
    today = DateTime.now(),
    isIOS = Platform.isIOS,
    fmd1 = DateFormat.MMMd(),
    isMac = Platform.isMacOS,
    dip = DeviceInfoPlugin(),
    isLinux = Platform.isLinux,
    la = MyLocalAuthentication(),
    thisMoment = TimeOfDay.now(),
    sc = TextEditingController(),
    tc = TextEditingController(),
    isCupertino = isIOS || isMac,
    auth = LocalAuthentication(),
    measurements = Measurements(),
    phc = TextEditingController(),
    pwc = TextEditingController(),
    sdc = TextEditingController(),
    edc = TextEditingController(),
    isAndroid = Platform.isAndroid,
    isWindows = Platform.isWindows,
    isFuchsia = Platform.isFuchsia,
    rg = RouteGenerator(flag: true),
    isPortable = isAndroid || isIOS,
    polylinePoints = PolylinePoints(),
    minDesignSize = const Size(360, 800),
    cm = getState<CommonState>(CommonState()),
    title = gc?.getValue<String>('name') ?? '',
    sharedPrefs = SharedPreferences.getInstance(),
    minPwdLth = gc?.getValue<String>('minimum_password_length').toInt() ?? 8,
    maxPwdLth = gc?.getValue<String>('maximum_password_length').toInt() ?? 16,
    splashScreenDelay =
        gc?.getValue<String>('splash_screen_delay').toInt() ?? 3,
    isWeb = !(isAndroid || isCupertino || isWindows || isLinux || isFuchsia) &&
        kIsWeb,
    spaceExp = RegExp(r'\s'),
    pwdExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$'),
    mailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
