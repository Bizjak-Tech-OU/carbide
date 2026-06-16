// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of the Carbide gallery and is licensed under the GNU
// Affero General Public License v3.0 or later.

import 'registry.dart';
import 'pages/foundations_pages.dart';
import 'pages/tier_a_pages.dart';
import 'pages/tier_b_pages.dart';
import 'pages/tier_c_pages.dart';
import 'pages/tier_d_pages.dart';

/// The full set of side-nav categories shown in the gallery.
final List<GalleryCategory> kCatalog = <GalleryCategory>[
  foundationsCategory,
  tierACategory,
  tierBCategory,
  tierCCategory,
  tierDCategory,
];
