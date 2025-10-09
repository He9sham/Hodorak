import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/theming/colors_manger.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/onboarding/widgets/custom_container_text_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  Future<void> _completeOnboarding() async {
    // Mark onboarding as seen
    await onboardingService.markOnboardingAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'ابدأ الان',
      onFinish: () async {
        await _completeOnboarding();
        if (mounted) {
          // ignore: use_build_context_synchronously
          context.pushNamed(Routes.loginScreen);
        }
      },
      finishButtonStyle: FinishButtonStyle(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: ColorsManager.buttonColor,
      ),
      skipTextButton: const Text(
        'تخطي',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      skipFunctionOverride: () async {
        await _completeOnboarding();
        if (mounted) {
          // ignore: use_build_context_synchronously
          context.pushNamed(Routes.loginScreen);
        }
      },
      controllerColor: Colors.black,
      totalPage: 2,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [
        Image.asset('assets/imageOnboarding/Group 9.png'),
        Image.asset(
          'assets/imageOnboarding/Moneyverse - Request Approved 1.png',
        ),
      ],
      speed: 1.8,
      pageBodies: const [
        CustomContainerTextView(
          title: 'Track Your Attendance',
          subtitle:
              'Check in easily with just a tap. Your attendance is safe and verified.',
        ),
        CustomContainerTextView(
          title: 'My Requests',
          subtitle:
              'Submit and track all your requests easily, from leave to schedule changes.',
        ),
      ],
    );
  }
}
