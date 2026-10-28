import 'package:flutter/material.dart';

/// Screen width breakpoints used to determine screen layout mode across the app.
class AppBreakpoints {
  AppBreakpoints._();

  /// Mobile breakpoint boundary (width < 600)
  static const double mobile = 600;

  /// Tablet breakpoint boundary (600 <= width < 900)
  static const double tablet = 900;

  /// Desktop breakpoint boundary (width >= 900)
  static const double desktop = 1200;

  /// Returns true if the viewport width is in mobile range (< 600px).
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < mobile;

  /// Returns true if the viewport width is in tablet range (600px to 899px).
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  /// Returns true if the viewport width is desktop or wider (>= 900px).
  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= tablet;
}

/// A custom layout wrapper that centers its [child] and restricts its width
/// to [maxWidth], preventing UI distortion on large desktop monitors.
class ResponsiveCenter extends StatelessWidget {
  /// Content widget inside the responsive container.
  final Widget child;

  /// Maximum allowed width for content on desktop (defaults to 1000px).
  final double maxWidth;

  /// Optional padding around the centered child.
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1000,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A responsive grid container that displays children in 1, 2, or 3+ columns
/// depending on viewport width (mobile, tablet, or desktop).
class ResponsiveGrid extends StatelessWidget {
  /// List of card or content widgets to display in grid format.
  final List<Widget> children;

  /// Horizontal spacing between items.
  final double spacing;

  /// Vertical spacing between rows.
  final double runSpacing;

  /// Number of grid columns on mobile view (< 600px).
  final int mobileCrossAxisCount;

  /// Number of grid columns on tablet view (600px - 1199px).
  final int tabletCrossAxisCount;

  /// Number of grid columns on desktop view (>= 1200px).
  final int desktopCrossAxisCount;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    int columns = mobileCrossAxisCount;
    if (width >= AppBreakpoints.desktop) {
      columns = desktopCrossAxisCount;
    } else if (width >= AppBreakpoints.mobile) {
      columns = tabletCrossAxisCount;
    }

    if (columns <= 1) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: runSpacing),
                  child: child,
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
        );
      },
    );
  }
}
