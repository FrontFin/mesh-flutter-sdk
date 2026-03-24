import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/mesh_sdk_version.dart';

void main() {
  test('sdkVersion matches pubspec.yaml version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final matcher = RegExp(r'^version:\s+(\S+)', multiLine: true);
    final match = matcher.firstMatch(pubspec);

    expect(match, isNotNull, reason: 'version field not found in pubspec.yaml');
    expect(
      sdkVersion,
      equals(match!.group(1)),
      reason: 'sdkVersion should match the version from pubspec.yaml',
    );
  });
}
