import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/src/auth_messages_android.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';
import 'package:local_auth_windows/types/auth_messages_windows.dart';

import '../extensions/extensions.dart';

class MyLocalAuthentication extends LocalAuthentication {
  static final MyLocalAuthentication _singleton =
      MyLocalAuthentication._internal();

  factory MyLocalAuthentication() {
    return _singleton;
  }

  MyLocalAuthentication._internal();

  Future<bool> confirm(String message,
          [AuthenticationOptions? options,
          Iterable<AuthMessages>? authMessages]) =>
      authenticate(
          localizedReason: message.trimmed,
          options: options ?? const AuthenticationOptions(),
          authMessages: authMessages ??
              const <AuthMessages>[
                IOSAuthMessages(),
                AndroidAuthMessages(),
                WindowsAuthMessages()
              ]);
}
