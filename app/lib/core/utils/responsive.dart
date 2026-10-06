import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Layout helpers implementing the Phase 2 breakpoint contract:
/// compact (< 600), medium (600–840), expanded (> 840).
class Responsive {
  Responsive._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.compact;

  static bool isMedium(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.compact && w < Breakpoints.expanded;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.expanded;

  /// Screen gutter: 24 on phones, 32 on large screens.
  static double screenPadding(BuildContext context) =>
      isExpanded(context) ? AppConstants.screenPaddingExpanded : AppConstants.screenPadding;

  /// True when the layout is wide enough for multi-column content.
  static bool canUseGrid(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.compact;

  /// Column count for responsive grids (1 / 2 / 3 based on width).
  static int gridColumns(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    if (w >= 1100) return 3;
    if (w >= Breakpoints.compact) return 2;
    return 1;
  }

  /// Convenience: a scroll view with a max-width content column.
  static Widget wrapInMaxWidth(
    BuildContext context,
    Widget child, {
    double maxWidth = AppConstants.contentMaxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
