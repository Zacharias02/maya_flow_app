/// Tracks whether the duplicate-account picker flow has already run this chat session.
/// When true, [buildSystemPrompt] tells the model not to emit another DuplicateProfileChoice.
/// Reset when [ChatController.init] starts a fresh conversation surface.
abstract final class DuplicateAccountFlowGate {
  static bool _completed = false;

  static bool get isCompleted => _completed;

  static void markCompleted() {
    _completed = true;
  }

  static void reset() {
    _completed = false;
  }
}
