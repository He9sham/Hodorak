import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/theming/styles.dart';

class CustomContainerTextView extends StatelessWidget {
  const CustomContainerTextView({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          verticalSpace(0.55),
          Text(title, style: Styles.textonbording23),
          verticalSpace(0.2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Styles.textonbording13,
          ),
        ],
      ),
    );
  }
}
