import 'dart:math';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:creative_park/app/verify/verify_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creative_park/app/top_level_providers.dart';
import 'package:creative_park/app/sign_in/sign_in_view_model.dart';
import 'package:creative_park/app/sign_in/sign_in_button.dart';
import 'package:creative_park/constants/keys.dart';
import 'package:creative_park/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:creative_park/routing/app_router.dart';

final signInModelProvider = ChangeNotifierProvider<SignInViewModel>(
  (ref) => SignInViewModel(auth: ref.watch(firebaseAuthProvider)),
);

class SignInPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final signInModel = watch(signInModelProvider);
    return ProviderListener<SignInViewModel>(
      provider: signInModelProvider,
      onChange: (context, model) async {
        if (model.error != null) {
          await showExceptionAlertDialog(
            context: context,
            title: Strings.signInFailed,
            exception: model.error,
          );
        }
      },
      child: SignInPageContents(
        viewModel: signInModel,
        title: 'Creatives\' Car Parking',
      ),
    );
  }
}

class SignInPageContents extends StatelessWidget {
  const SignInPageContents({Key? key, required this.viewModel, this.title = 'Architecture Demo'}) : super(key: key);
  final SignInViewModel viewModel;
  final String title;

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      AppRoutes.emailPasswordSignInPage,
      arguments: () async {
        final user = viewModel.auth.currentUser!;
        if (!user.emailVerified) {
          user.sendEmailVerification();
        } else {
          await verifyEmail(context);
        }
        navigator.pop();
      },
    );
  }

  Future<void> verifyEmail(BuildContext context) async {
    final verifyViewModel = context.read(verifyViewModelProvider.notifier);
    await verifyViewModel.verifyEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const Text(
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32.0),
              SizedBox(
                height: 50.0,
                child: _buildHeader(),
              ),
              const SizedBox(height: 32.0),
              SignInButton(
                key: emailPasswordButtonKey,
                text: Strings.signInWithEmailPassword,
                onPressed: viewModel.isLoading ? null : () => _showEmailPasswordSignInPage(context),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
              ),
//              const SizedBox(height: 8),
//              const Text(
//                Strings.or,
//                style: TextStyle(fontSize: 14.0, color: Colors.black87),
//                textAlign: TextAlign.center,
//              ),
//              const SizedBox(height: 8),
//              SignInButton(
//                key: anonymousButtonKey,
//                text: Strings.goAnonymous,
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                onPressed: viewModel.isLoading ? null : viewModel.signInAnonymously,
//              ),
            ],
          ),
        );
      }),
    );
  }
}
