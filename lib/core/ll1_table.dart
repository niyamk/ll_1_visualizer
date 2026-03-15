import '../models/production.dart';
import 'grammar.dart';
import 'first_follow.dart';

/// LL(1) Parsing Table
///
/// Table[A][a] = production to use when:
///   - A is on top of the stack
///   - a is the current lookahead token
///
/// Filling rules:
///   For each production A -> α:
///     1. For each terminal a in FIRST(α):
///            add A -> α  to  Table[A][a]
///     2. If ε ∈ FIRST(α):
///            for each terminal b in FOLLOW(A):
///              add A -> α  to  Table[A][b]
///
/// If any cell gets two entries → CONFLICT → grammar is NOT LL(1)
class LL1Table {
  final Grammar grammar;
  final FirstFollow ff;

  /// table[nonTerminal][terminal] = Production
  Map<String, Map<String, Production>> table = {};
  bool hasConflict = false;
  List<String> conflicts = [];

  LL1Table(this.grammar, this.ff);

  void build() {
    // Initialise empty rows for every non-terminal
    for (final nt in grammar.nonTerminals) {
      table[nt] = {};
    }

    for (final p in grammar.productions) {
      final firstAlpha = ff.firstOfSequence(p.rhs);

      // Rule 1: for each terminal in FIRST(α)
      for (final terminal in firstAlpha) {
        if (terminal == 'ε') continue;
        _setEntry(p.lhs, terminal, p);
      }

      // Rule 2: if ε ∈ FIRST(α), use FOLLOW(A)
      if (firstAlpha.contains('ε')) {
        for (final terminal in ff.follow[p.lhs] ?? {}) {
          _setEntry(p.lhs, terminal, p);
        }
      }
    }
  }

  void _setEntry(String nt, String terminal, Production p) {
    final existing = table[nt]?[terminal];
    if (existing != null && existing.index != p.index) {
      hasConflict = true;
      conflicts.add(
        'CONFLICT at M[$nt, $terminal]: '
        '"$existing"  vs  "$p"',
      );
      return; // keep first entry
    }
    table[nt]![terminal] = p;
  }

  // ── PRINT ─────────────────────────────────────────────────────────────────

  void printTable() {
    print('\n=== LL(1) PARSING TABLE ===');

    final termCols = <String>[...grammar.terminals, r'$']..sort();
    final ntRows   = grammar.nonTerminals.toList()..sort();
    final colW     = 18;
    final ntW      = 8;

    // Header
    print('  ${'NT'.padRight(ntW)} ${termCols.map((t) => t.padRight(colW)).join()}');
    print('  ${'-' * (ntW + termCols.length * colW + 2)}');

    for (final nt in ntRows) {
      String row = '  ${nt.padRight(ntW)}';
      for (final t in termCols) {
        final entry = table[nt]?[t];
        row += (entry?.toString() ?? '').padRight(colW);
      }
      print(row);
    }

    if (hasConflict) {
      print('\n  ⚠  CONFLICTS DETECTED:');
      for (final c in conflicts) print('    $c');
      print('  → Grammar is NOT LL(1)');
    } else {
      print('\n  ✓  No conflicts — Grammar is LL(1)');
    }
  }
}