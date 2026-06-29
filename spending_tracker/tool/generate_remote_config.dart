#!/usr/bin/env dart
// Generates firebase/remote_config_template.json for Firebase Console import.
// Run: dart run tool/generate_remote_config.dart

import 'dart:convert';
import 'dart:io';

import 'package:new_spendz/core/config/app_config.dart';

void main() {
  final defaults = AppConfig.remoteConfigDefaults;
  final parameters = <String, dynamic>{};

  for (final entry in defaults.entries) {
    final value = entry.value;
    parameters[entry.key] = {
      'defaultValue': {
        'value': value is bool ? value.toString() : value.toString(),
      },
      'description': _description(entry.key),
      'valueType': value is bool ? 'BOOLEAN' : 'STRING',
    };
  }

  final output = {
    'parameters': parameters,
    'version': {
      'versionNumber': '1',
      'updateTime': DateTime.now().toUtc().toIso8601String(),
      'updateUser': {'email': 'hello@cyfur.in'},
      'description': 'ZenSpend initial Remote Config',
    },
  };

  final file = File('firebase/remote_config_template.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(output));
  stdout.writeln('Wrote ${file.path}');
}

String _description(String key) {
  return switch (key) {
    AppConfig.rcMinVersionAndroid => 'Force update below this version (Android).',
    AppConfig.rcMinVersionIos => 'Force update below this version (iOS).',
    AppConfig.rcLatestVersion => 'Latest published app version.',
    AppConfig.rcForceUpdate => 'When true, users below latest_version must update.',
    AppConfig.rcUpdateMessage => 'Message shown in the update dialog.',
    AppConfig.rcPlayStoreUrl => 'Google Play listing URL.',
    AppConfig.rcAppStoreUrl => 'Apple App Store listing URL.',
    AppConfig.rcPrivacyPolicy => 'Full Privacy Policy text (in-app).',
    AppConfig.rcTermsOfService => 'Full Terms of Service text (in-app).',
    AppConfig.rcPrivacyPolicyUpdated => 'Privacy Policy last updated label.',
    AppConfig.rcTermsUpdated => 'Terms last updated label.',
    AppConfig.rcSupportEmail => 'Support email shown in About.',
    _ => 'ZenSpend Remote Config parameter.',
  };
}
