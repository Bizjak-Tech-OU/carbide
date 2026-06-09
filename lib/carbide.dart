// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Carbide is an unofficial, independent port of the IBM Carbon Design System.
// It is not affiliated with, endorsed by, or sponsored by IBM. "IBM",
// "Carbon", and "IBM Plex" are trademarks of International Business Machines
// Corporation. Design tokens are derived from the Apache-2.0 licensed Carbon
// Design System; see the NOTICE file for attribution.

/// Carbide — an unofficial Flutter port of the IBM Carbon Design System.
///
/// Carbide is built strictly on `package:flutter/widgets.dart`. It deliberately
/// does not depend on Material or Cupertino: every token, theme, and component
/// is implemented from Flutter's base widgets so the result matches Carbon's
/// specification rather than Material's.
///
/// Public API is exported from this barrel as each layer lands. Foundations
/// (design tokens) are tracked in milestone M1, theming in M2, and components
/// from M4 onward.
library;

// Foundations — design tokens.
export 'src/foundations/colors.dart';
export 'src/foundations/fonts.dart';
