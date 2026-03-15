import '../models/parse_step.dart';
import 'grammar.dart';
import 'll1_table.dart';

/// LL(1) Stack-Based Parser
///
/// Algorithm:
///   Push $ then startSymbol onto stack.
///   Read first token as lookahead.
///
///   Loop:
///     X = top of stack,  a = lookahead
///     if X == a == $  →  ACCEPT
///     if X == a       →  match: pop X, advance input
///     if X is terminal but X ≠ a  →  ERROR
///     if X is non-terminal:
///       look up Table[X][a]
///       if empty  →  ERROR
///       pop X, push RHS in reverse (so first symbol ends up on top)
class LL1Parser {
  final Grammar grammar;
  final LL1Table table;
  List<ParseStep> steps = [];

  LL1Parser(this.grammar, this.table);

  /// Tokenizes the input string — supports both space-separated
  /// and no-space formats, and handles multi-char terminals like "id".
  List<String> tokenize(String input) {
    final tokens = <String>[];
    final cleaned = input.trim();
    int i = 0;

    while (i < cleaned.length) {
      if (cleaned[i] == ' ') { i++; continue; }

      // Try greedy match against known terminals (longest first)
      final sortedTerminals = grammar.terminals.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      bool matched = false;
      for (final term in sortedTerminals) {
        if (cleaned.startsWith(term, i)) {
          tokens.add(term);
          i += term.length;
          matched = true;
          break;
        }
      }

      if (!matched) {
        // Single character fallback
        tokens.add(cleaned[i]);
        i++;
      }
    }

    tokens.add(r'$');
    return tokens;
  }

  bool parse(String inputString) {
    steps = [];

    final tokens = tokenize(inputString);
    final stack  = <String>[r'$', grammar.startSymbol];
    int pos = 0;

    while (true) {
      final x = stack.last;
      final a = tokens[pos];

      // Snapshot for this step
      final stackSnap = List<String>.from(stack.reversed);
      final inputSnap = tokens.sublist(pos);

      // ── ACCEPT ──────────────────────────────────────────────────────────
      if (x == r'$' && a == r'$') {
        steps.add(ParseStep(
          stack: stackSnap,
          input: inputSnap,
          action: 'ACCEPT ✓',
        ));
        return true;
      }

      // ── MATCH (terminal on top matches lookahead) ────────────────────────
      if (!grammar.isNonTerminal(x)) {
        if (x == a) {
          steps.add(ParseStep(
            stack: stackSnap,
            input: inputSnap,
            action: 'Match "$a" — pop & advance',
          ));
          stack.removeLast();
          pos++;
        } else {
          steps.add(ParseStep(
            stack: stackSnap,
            input: inputSnap,
            action: 'ERROR — expected "$x" but got "$a"',
          ));
          return false;
        }
        continue;
      }

      // ── EXPAND (non-terminal on top) ─────────────────────────────────────
      final production = table.table[x]?[a];

      if (production == null) {
        steps.add(ParseStep(
          stack: stackSnap,
          input: inputSnap,
          action: 'ERROR — no entry in table for [$x, $a]',
        ));
        return false;
      }

      steps.add(ParseStep(
        stack: stackSnap,
        input: inputSnap,
        action: 'Apply: $production',
      ));

      stack.removeLast(); // pop X

      // Push RHS in reverse so first symbol is on top
      if (!production.isEpsilon) {
        for (final sym in production.rhs.reversed) {
          stack.add(sym);
        }
      }
      // If ε-production: just pop, push nothing
    }
  }

  // ── PRINT ─────────────────────────────────────────────────────────────────

  void printTrace() {
    print('\n=== PARSING TRACE ===');
    const stackW  = 30;
    const inputW  = 25;

    print('  ${'Stack'.padRight(stackW)} ${'Input'.padRight(inputW)} Action');
    print('  ${'-' * (stackW + inputW + 40)}');

    for (final step in steps) {
      // Stack: show top-of-stack on right (conventional notation)
      final stackStr = step.stack.reversed.join(' ');
      final inputStr = step.input.join(' ');
      print('  ${stackStr.padRight(stackW)} ${inputStr.padRight(inputW)} ${step.action}');
    }
  }
}