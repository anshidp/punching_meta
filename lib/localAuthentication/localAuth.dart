import 'package:local_auth/local_auth.dart';

class LocalAuth {
  static final auth = LocalAuthentication();
  static Future<bool> canAuthenticate() async {
    return await auth.canCheckBiometrics &&
        (await auth.getAvailableBiometrics()).contains(BiometricType.face);
  }

  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) {
        return false;
      }
      final type = await auth.getAvailableBiometrics();

      print("type $type");
      return await auth.authenticate(
          localizedReason: "Use face id authenticate",
          options: const AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true));
    } catch (e) {
      return false;
    }
  }










  
}
