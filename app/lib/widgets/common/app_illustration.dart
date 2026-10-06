import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_icons.dart';

/// Renders one of the hand-crafted illustrations.
class AppIllustration extends StatelessWidget {
  const AppIllustration(
    this.illustration, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// Illustration name from [IllustrationAssets].
  final String illustration;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      IllustrationAssets.get(illustration),
      width: width,
      height: height,
      fit: fit,
      semanticsLabel: 'illustration',
    );
  }
}
