// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Carbide ships no public API yet: the foundation/tooling milestone (M0)
  // establishes the package, licensing, and CI only. Real behaviour and its
  // tests arrive with the design tokens in milestone M1. Each token group and
  // component lands with its own state-matrix, golden, and semantics tests, as
  // required by the project's definition of done.
  test('package skeleton loads', () {
    expect(1 + 1, 2);
  });
}
