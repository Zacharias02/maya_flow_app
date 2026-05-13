import 'dart:convert';

import '../session/duplicate_account_flow_gate.dart';
import '../../catalog/maya_catalog.dart' show mayaCatalogId;

/// JSONL object (single line) — [updateComponents] for [DuplicateProfileChoice].
String jsonLineUpdateDuplicateProfileChoice(String surfaceId) {
  return jsonEncode({
    'version': 'v0.9',
    'updateComponents': {
      'surfaceId': surfaceId,
      'components': [
        {
          'id': 'root',
          'component': 'DuplicateProfileChoice',
          'question': 'Which profile should we keep on file?',
          'subtitle': 'The other will be queued for removal.',
          'notificationEmail': 'gabgarrero@gmail.com',
          'choices': [
            {
              'id': 'keep_alpha',
              'title': 'Keep Alpha',
              'subtitle':
                  'Remove Beta | MCH-DUP-BETA-02 | @gabgarero | gab.garrero@gmail.com',
            },
            {
              'id': 'keep_beta',
              'title': 'Keep Beta',
              'subtitle':
                  'Remove Alpha | MCH-DUP-ALPHA-01 | @gabgarrero | gabgarrero@gmail.com',
            },
          ],
        },
      ],
    },
  });
}

/// When the model answers a duplicate-account question in plain text only (no
/// A2UI), the picker never mounts. If the reply clearly sets up the two demo
/// profiles and the user (or assistant) indicates duplicate resolution, append
/// canonical JSONL so [DuplicateProfileChoice] still renders.
String ensureDuplicateProfileChoiceFallback({
  required String userPrompt,
  required String assistantText,
}) {
  if (DuplicateAccountFlowGate.isCompleted) return assistantText;
  if (assistantText.trim().isEmpty) return assistantText;
  if (_outputAlreadyHasDuplicateWidget(assistantText)) return assistantText;

  if (!_assistantSetsUpDuplicateProfiles(assistantText)) return assistantText;

  final user = userPrompt.toLowerCase();
  if (!_userMentionsDuplicateConcern(user) &&
      !_assistantOpensDuplicateAccountTopic(assistantText)) {
    return assistantText;
  }

  final sid = 'dup_auto_${DateTime.now().millisecondsSinceEpoch}';
  final create = jsonEncode({
    'version': 'v0.9',
    'createSurface': {
      'surfaceId': sid,
      'catalogId': mayaCatalogId,
    },
  });
  final update = jsonLineUpdateDuplicateProfileChoice(sid);

  final base = assistantText.trimRight();
  final sep = base.endsWith('\n') ? '\n' : '\n\n';
  return '$base$sep$create\n$update';
}

bool _outputAlreadyHasDuplicateWidget(String s) {
  return s.contains('DuplicateProfileChoice');
}

bool _assistantSetsUpDuplicateProfiles(String assistantText) {
  final t = assistantText.toLowerCase();
  if (t.contains('mch-dup-')) return true;
  if (t.contains('profile alpha') &&
      (t.contains('profile beta') || t.contains(' beta'))) {
    return true;
  }
  if (t.contains('two profiles')) return true;
  return false;
}

bool _userMentionsDuplicateConcern(String userLower) {
  if (userLower.isEmpty) return false;
  if (userLower.contains('duplicate')) return true;
  if (userLower.contains('dupl')) return true;
  if (userLower.contains('two profile')) return true;
  if (userLower.contains('two maya')) return true;
  if (userLower.contains('merge') &&
      (userLower.contains('account') || userLower.contains('profile'))) {
    return true;
  }
  if (userLower.contains('which') &&
      userLower.contains('keep') &&
      (userLower.contains('profile') || userLower.contains('account'))) {
    return true;
  }
  return false;
}

bool _assistantOpensDuplicateAccountTopic(String assistantText) {
  final t = assistantText.toLowerCase();
  return t.contains('duplicate account') ||
      t.contains('potential duplicate') ||
      t.contains('duplicate profile') ||
      t.contains('flagged a potential duplicate');
}
