import 'dart:convert';

/// GenUI may push malformed A2UI as [TextEvent] (see `A2uiParserTransformer._emitMessage`).
/// That shows up as raw JSON in chat. Remove well-formed `{"version":"v0.9" ... }` blobs.
String stripLeakedA2UiJsonFromAssistantText(String text) {
  if (!text.contains('"version"')) return text;

  final versionPattern = RegExp(r'\{\s*"version"\s*:\s*"v0\.9"');
  var result = text;

  for (;;) {
    final match = versionPattern.firstMatch(result);
    if (match == null) break;

    final start = match.start;
    final jsonStr = _extractBalancedBrace(result, start);
    if (jsonStr == null) break;

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map) break;
      final m = Map<String, dynamic>.from(decoded);
      if (m['version'] != 'v0.9') break;

      result = result.replaceRange(start, start + jsonStr.length, '');
      continue;
    } on FormatException {
      break;
    }
  }

  return result.replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
}

/// Extracts one balanced `{ ... }` substring starting at [start] (must be `{`).
String? _extractBalancedBrace(String s, int start) {
  if (start >= s.length || s[start] != '{') return null;

  var balance = 0;
  var inString = false;
  var escaped = false;

  for (var i = start; i < s.length; i++) {
    final c = s[i];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (c == r'\') {
      escaped = true;
      continue;
    }
    if (c == '"') {
      inString = !inString;
      continue;
    }
    if (!inString) {
      if (c == '{') {
        balance++;
      } else if (c == '}') {
        balance--;
        if (balance == 0) {
          return s.substring(start, i + 1);
        }
      }
    }
  }
  return null;
}
