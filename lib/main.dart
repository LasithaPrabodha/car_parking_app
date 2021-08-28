//import 'package:auth_widget_builder/auth_widget_builder.dart';
import 'package:creative_park/app/verify/verify_view_model.dart';

import 'app/verify/verification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creative_park/app/auth_widget.dart';
import 'package:creative_park/app/home_page.dart';
import 'package:creative_park/app/onboarding/onboarding_page.dart';
import 'package:creative_park/app/onboarding/onboarding_view_model.dart';
import 'package:creative_park/app/top_level_providers.dart';
import 'package:creative_park/app/sign_in/sign_in_page.dart';
import 'package:creative_park/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creative_park/services/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final didCompleteOnboarding = watch(onboardingViewModelProvider);
            return didCompleteOnboarding ? SignInPage() : OnboardingPage();
          },
        ),
        signedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final auth = context.read(firebaseAuthProvider);
            final isEmailVerified = watch(verifyViewModelProvider);

            return auth.currentUser?.emailVerified == true || isEmailVerified
                ? const HomePage()
                : const VerificationPage();
          },
        ),
      ),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings, firebaseAuth),
    );
  }
}
