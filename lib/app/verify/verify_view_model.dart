import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creative_park/services/shared_preferences_service.dart';
import 'package:state_notifier/state_notifier.dart';

final verifyViewModelProvider = StateNotifierProvider<VerifyViewModel, bool>((ref) {
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);
  return VerifyViewModel(sharedPreferencesService);
});

class VerifyViewModel extends StateNotifier<bool> {
  VerifyViewModel(this.sharedPreferencesService) : super(sharedPreferencesService.isVerifiedEmail());
  final SharedPreferencesService sharedPreferencesService;

  Future<void> verifyEmail() async {
    await sharedPreferencesService.setVerifiedEmail();
    state = true;
  }

  Future<void> reset() async {
    await sharedPreferencesService.reset();
    state = false;
  }


  bool get isVerifiedEmail => state;
}
