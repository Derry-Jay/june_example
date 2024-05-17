import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:yaml/yaml.dart';

import '../extensions/extensions.dart';
import 'app.dart';
import 'models/common/app_config.dart';
import 'models/common/custom_http.dart';
import 'utils/methods.dart';
import 'utils/values.dart';

void main() async {
  try {
    wb = WidgetsFlutterBinding.ensureInitialized();
    gc = await GlobalConfiguration().loadFromAsset('config');
    HttpOverrides.global = CustomHttp();
    acf = AppConfig.fromJson(jsonDecode(jsonEncode(
                loadYaml(await rootBundle.loadString('pubspec.yaml'))))
            as Map<String, Object?>? ??
        <String, Object?>{});
    (wb?.buildOwner?.debugBuilding ?? true)
        ? doNothing()
        : runApp(const MyApp());
  } catch (e) {
    e.jot;
  }
}
