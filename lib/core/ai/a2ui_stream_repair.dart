import 'dart:convert';

import 'a2ui_duplicate_fallback.dart';

/// Inserts a missing `createSurface` line before a lone `updateComponents` that
/// targets [DuplicateProfileChoice], which otherwise fails GenUI validation
/// (surface must exist) or leaves raw JSON in the chat.
///
/// Handles both compact JSONL and pretty-printed multi-line JSON objects.
String repairMayaA2UiAssistantText(String raw) {
  final seenCreateSurface = <String>{};
  final sb = StringBuffer();
  var idx = 0;
  while (idx < raw.length) {
    final open = raw.indexOf('{', idx);
    if (open == -1) {
      sb.write(raw.substring(idx));
      break;
    }
    sb.write(raw.substring(idx, open));
    final close = _closingBraceIndex(raw, open);
    if (close == -1) {
      sb.write(raw.substring(open));
      break;
    }
    final jsonStr = raw.substring(open, close + 1);
    idx = close + 1;

    Map<String, dynamic>? m;
    try {
      m = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      sb.write(jsonStr);
      continue;
    }

    if (m['version'] == 'v0.9' && m.containsKey('createSurface')) {
      final cs = m['createSurface'];
      if (cs is Map && cs['surfaceId'] is String) {
        seenCreateSurface.add(cs['surfaceId'] as String);
      }
    }

    if (m['version'] == 'v0.9' && m.containsKey('updateComponents')) {
      final uc = m['updateComponents'];
      if (uc is Map<String, dynamic>) {
        final sid = uc['surfaceId'] as String?;
        final comps = uc['components'];
        if (sid != null &&
            comps is List &&
            _componentsIncludeDuplicateProfileChoice(comps) &&
            !seenCreateSurface.contains(sid)) {
          sb.write(
            jsonEncode({
              'version': 'v0.9',
              'createSurface': {
                'surfaceId': sid,
                'catalogId': 'maya-catalog',
              },
            }),
          );
          sb.write('\n');
          seenCreateSurface.add(sid);
        }
      }
    }

    sb.write(jsonStr);
  }
  return sb.toString();
}

/// Appends [DuplicateProfileChoice] [updateComponents] when the model emitted
/// `createSurface` for a `dup…` surface (e.g. `dup_pick_1` from the prompt
/// example) but omitted the matching [updateComponents] line — GenUI then logs
/// "has no root component".
String ensureOrphanDupCreatesHaveUpdateComponents(String raw) {
  final updatedSurfaceIds = _collectUpdateComponentsSurfaceIds(raw);
  final orphanDupSurfaceIds = _collectOrphanDupCreateSurfaceIds(
    raw,
    updatedSurfaceIds,
  );
  if (orphanDupSurfaceIds.isEmpty) return raw;

  final sb = StringBuffer(raw.trimRight());
  for (final sid in orphanDupSurfaceIds) {
    sb.write('\n');
    sb.write(jsonLineUpdateDuplicateProfileChoice(sid));
  }
  return sb.toString();
}

Set<String> _collectUpdateComponentsSurfaceIds(String raw) {
  final out = <String>{};
  var idx = 0;
  while (idx < raw.length) {
    final open = raw.indexOf('{', idx);
    if (open == -1) break;
    final close = _closingBraceIndex(raw, open);
    if (close == -1) break;
    final jsonStr = raw.substring(open, close + 1);
    idx = close + 1;
    Map<String, dynamic>? m;
    try {
      m = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    if (m['version'] != 'v0.9' || !m.containsKey('updateComponents')) continue;
    final uc = m['updateComponents'];
    if (uc is Map && uc['surfaceId'] is String) {
      out.add(uc['surfaceId'] as String);
    }
  }
  return out;
}

/// Preserves document order; de-duplicates surface ids.
List<String> _collectOrphanDupCreateSurfaceIds(
  String raw,
  Set<String> updatedSurfaceIds,
) {
  final ordered = <String>[];
  final seen = <String>{};
  var idx = 0;
  while (idx < raw.length) {
    final open = raw.indexOf('{', idx);
    if (open == -1) break;
    final close = _closingBraceIndex(raw, open);
    if (close == -1) break;
    final jsonStr = raw.substring(open, close + 1);
    idx = close + 1;
    Map<String, dynamic>? m;
    try {
      m = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    if (m['version'] != 'v0.9' || !m.containsKey('createSurface')) continue;
    final cs = m['createSurface'];
    if (cs is! Map) continue;
    if (cs['catalogId'] != 'maya-catalog') continue;
    final sid = cs['surfaceId'];
    if (sid is! String || !sid.startsWith('dup')) continue;
    if (updatedSurfaceIds.contains(sid)) continue;
    if (seen.add(sid)) ordered.add(sid);
  }
  return ordered;
}

bool _componentsIncludeDuplicateProfileChoice(List<dynamic> comps) {
  for (final c in comps) {
    if (c is! Map) continue;
    if (c['component'] == 'DuplicateProfileChoice') return true;
  }
  return false;
}

/// Returns index of `}` that closes the object starting at [openBrace], or -1.
int _closingBraceIndex(String input, int openBrace) {
  var balance = 0;
  var inString = false;
  var escaped = false;
  for (var i = openBrace; i < input.length; i++) {
    final char = input[i];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char == r'\') {
      escaped = true;
      continue;
    }
    if (char == '"') {
      inString = !inString;
      continue;
    }
    if (!inString) {
      if (char == '{') {
        balance++;
      } else if (char == '}') {
        balance--;
        if (balance == 0) {
          return i;
        }
      }
    }
  }
  return -1;
}
