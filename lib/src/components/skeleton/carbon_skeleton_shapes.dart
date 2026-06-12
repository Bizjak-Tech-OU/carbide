// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/skeleton-styles/_skeleton-styles.scss
//   styles/scss/components/button/_button.scss (.cds--btn.cds--skeleton)
//   styles/scss/components/tag/_tag.scss (.cds--tag.cds--skeleton)

import 'package:flutter/widgets.dart';

import '../button/carbon_button.dart';
import 'carbon_skeleton.dart';

/// A plain rectangular loading placeholder; 100×100 by default.
class CarbonSkeletonPlaceholder extends StatelessWidget {
  /// Creates a placeholder skeleton.
  const CarbonSkeletonPlaceholder({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  /// The placeholder width (spec default 100).
  final double width;

  /// The placeholder height (spec default 100).
  final double height;

  @override
  Widget build(BuildContext context) =>
      CarbonSkeleton(width: width, height: height);
}

/// A loading placeholder for an icon; 16×16 by default.
class CarbonSkeletonIcon extends StatelessWidget {
  /// Creates an icon skeleton.
  const CarbonSkeletonIcon({super.key, this.size = 16});

  /// The icon edge length (spec default 16).
  final double size;

  @override
  Widget build(BuildContext context) =>
      CarbonSkeleton(width: size, height: size);
}

/// A loading placeholder for a [CarbonButton]; 150px wide at the button
/// height of [size].
class CarbonButtonSkeleton extends StatelessWidget {
  /// Creates a button skeleton.
  const CarbonButtonSkeleton({super.key, this.size = CarbonButtonSize.lg});

  /// The button size whose height to match.
  final CarbonButtonSize size;

  /// The skeleton button width per spec.
  static const double width = 150;

  @override
  Widget build(BuildContext context) =>
      CarbonSkeleton(width: width, height: size.height);
}

/// The Carbon tag heights, shared by the tag skeleton (and the Tag
/// component when it lands).
enum CarbonTagSize {
  /// 18px.
  sm(18),

  /// 24px.
  md(24),

  /// 32px.
  lg(32);

  const CarbonTagSize(this.height);

  /// The tag height in logical pixels.
  final double height;
}

/// A loading placeholder for a tag: a 60px pill.
class CarbonTagSkeleton extends StatelessWidget {
  /// Creates a tag skeleton.
  const CarbonTagSkeleton({super.key, this.size = CarbonTagSize.md});

  /// The tag size whose height to match.
  final CarbonTagSize size;

  /// The skeleton tag width per spec.
  static const double width = 60;

  @override
  Widget build(BuildContext context) => CarbonSkeleton(
    width: width,
    height: size.height,
    borderRadius: BorderRadius.circular(16),
  );
}
