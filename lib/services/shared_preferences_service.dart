import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

class SharedPreferencesService {
  SharedPreferencesService(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';

  bool _isVerifiedEmail = false;

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  setVerifiedEmail() {
    _isVerifiedEmail = true;
  }

  reset() {
    _isVerifiedEmail = false;
  }

  bool isOnboardingComplete() => sharedPreferences.getBool(onboardingCompleteKey) ?? false;

  bool isVerifiedEmail() => _isVerifiedEmail;
}
