import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Constrains content to the max comfortable reading width on large screens.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets effective = padding ?? EdgeInsets.zero;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppConstants.contentMaxWidth),
        child: Padding(padding: effective, child: child),
      ),
    );
  }
}
