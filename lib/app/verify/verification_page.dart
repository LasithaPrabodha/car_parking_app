import 'dart:async';

import 'package:creative_park/app/home_page.dart';
import 'package:creative_park/app/top_level_providers.dart';
import 'package:creative_park/app/verify/verify_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late Timer _timer;

  Future<void> verifyEmail() async {
    final verifyViewModel = context.read(verifyViewModelProvider.notifier);
    await verifyViewModel.verifyEmail();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      bool isVerified = await checkEmailVerified();

      if (isVerified) verifyEmail();
    });
  }

  Future<bool> checkEmailVerified() async {
    await context.read(firebaseAuthProvider).currentUser!.reload();

    final firebaseAuth = context.read(firebaseAuthProvider);
    User user = firebaseAuth.currentUser!;

    return user.emailVerified;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    User user = firebaseAuth.currentUser!;

    return Scaffold(
      body: Center(
        child: Text(
          'An email has been sent to ${user.email}. Please verify.',
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
