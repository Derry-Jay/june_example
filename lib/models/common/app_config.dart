import '../../../extensions/extensions.dart';
import '../../utils/methods.dart';

class AppConfig {
  int buildNo = 0;
  String name = '',
      version = '',
      publishTo = '',
      sdkVersion = '',
      description = '',
      assetImagePath = '',
      versionAndBuild = '';

  static final AppConfig _singleton = AppConfig._internal();

  factory AppConfig() {
    return _singleton;
  }

  AppConfig._internal();

  AppConfig.fromJson(Map<String, Object?> json) {
    try {
      versionAndBuild = json['version'].string;
      final vb = versionAndBuild.split('+');
      version = vb.first;
      name = json['name'].string;
      buildNo = vb.last.toInt(null, 0);
      publishTo = json['publish_to'].string;
      description = json['description'].string;
      sdkVersion = (json['environment'] as Map<String, Object?>? ??
              <String, Object?>{})['sdk']
          .string;
      assetImagePath = List<String>.from(
              (json['flutter'] as Map<String, Object?>? ??
                      <String, Object?>{})['assets'] as Iterable? ??
                  const Iterable.empty())
          .firstWhere(isImagePath, orElse: emptyString);
    } catch (e) {
      e.jot();
    }
  }
}
