/// One step in the LL(1) parsing trace.
class ParseStep {
  final List<String> stack;   // current stack contents (top first)
  final List<String> input;   // remaining input tokens
  final String action;        // what happened at this step

  ParseStep({
    required this.stack,
    required this.input,
    required this.action,
  });
}