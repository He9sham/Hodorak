import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
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
      finishButtonText: 'Start Now',
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
      skipTextButton: Text(
        'Skip',
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      skipFunctionOverride: () async {
        await _completeOnboarding();
        if (mounted) {
          // ignore: use_build_context_synchronously
          context.pushNamed(Routes.loginScreen);
        }
      },
      controllerColor: Color(0xff8C9F5F),
      totalPage: 2,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [
        Image.asset(
          'assets/imageOnboarding/Group 9.png',
          height: sizeOfHeight(0.35, context),
        ),
        Image.asset(
          'assets/imageOnboarding/Moneyverse - Request Approved 1.png',
          height: sizeOfHeight(0.47, context),
        ),
      ],
      speed: 1.8,
      pageBodies: [
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
