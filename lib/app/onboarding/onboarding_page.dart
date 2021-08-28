import 'package:custom_buttons/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creative_park/app/onboarding/onboarding_view_model.dart';

class OnboardingPage extends StatelessWidget {
  Future<void> onGetStarted(BuildContext context) async {
    final onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
    await onboardingViewModel.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FractionallySizedBox(
              widthFactor: 0.5,
              child: Image(image: AssetImage('assets/CreativeLogo.png')),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'Car Parking',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 24,
            ),
            CustomRaisedButton(
              onPressed: () => onGetStarted(context),
              borderRadius: 30,
              color: Colors.red,
              child: Text(
                'Get Started',
                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
