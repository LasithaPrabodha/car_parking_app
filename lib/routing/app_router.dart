import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(
              firebaseAuth: firebaseAuth, onSignedIn: args as void Function(), allowedDomain: 'creativesoftware.com'),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        // TODO: Throw
        return null;
    }
  }
}
