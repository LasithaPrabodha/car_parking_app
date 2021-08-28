import 'dart:async';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:creative_park/app/top_level_providers.dart';
import 'package:creative_park/app/verify/verify_view_model.dart';
import 'package:creative_park/constants/keys.dart';
import 'package:creative_park/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.homePage),
        actions: <Widget>[
          FlatButton(
            key: const Key(Keys.logout),
            child: const Text(
              Strings.logout,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () => _confirmSignOut(context, firebaseAuth),
          ),
        ],
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context, firebaseAuth);
    }
  }

  Future<void> _signOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    try {
      await firebaseAuth.signOut();
      await resetEmailVerification(context);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }


  Future<void> resetEmailVerification(BuildContext context) async {
    final verifyViewModel = context.read(verifyViewModelProvider.notifier);
    await verifyViewModel.reset();
  }
}
