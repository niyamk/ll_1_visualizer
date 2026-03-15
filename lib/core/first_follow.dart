import 'grammar.dart';

/// Computes FIRST and FOLLOW sets for all non-terminals.
///
/// FIRST(X)  = set of terminals that can begin any string derived from X
/// FOLLOW(A) = set of terminals that can appear immediately after A
class FirstFollow {
  final Grammar grammar;
  Map<String, Set<String>> first = {};
  Map<String, Set<String>> follow = {};

  FirstFollow(this.grammar);

  void compute() {
    _computeFirst();
    _computeFollow();
  }

  // ── FIRST ─────────────────────────────────────────────────────────────────

  void _computeFirst() {
    // Initialise
    for (final nt in grammar.nonTerminals) first[nt] = {};
    for (final t  in grammar.terminals)    first[t]  = {t};
    first['ε'] = {'ε'};
    first[r'$'] = {r'$'};

    bool changed = true;
    while (changed) {
      changed = false;
      for (final p in grammar.productions) {
        final before = first[p.lhs]!.length;
        first[p.lhs]!.addAll(firstOfSequence(p.rhs));
        if (first[p.lhs]!.length != before) changed = true;
      }
    }
  }

  /// FIRST of a sequence of symbols — used for both FIRST computation
  /// and for filling the parsing table.
  Set<String> firstOfSequence(List<String> symbols) {
    final result = <String>{};

    if (symbols.isEmpty || (symbols.length == 1 && symbols[0] == 'ε')) {
      return {'ε'};
    }

    bool allNullable = true;
    for (final sym in symbols) {
      final f = first[sym] ?? {sym};
      result.addAll(f.where((s) => s != 'ε'));
      if (!f.contains('ε')) { allNullable = false; break; }
    }
    if (allNullable) result.add('ε');
    return result;
  }

  // ── FOLLOW ────────────────────────────────────────────────────────────────

  void _computeFollow() {
    for (final nt in grammar.nonTerminals) follow[nt] = {};

    // $ is always in FOLLOW of start symbol
    follow[grammar.startSymbol]!.add(r'$');

    bool changed = true;
    while (changed) {
      changed = false;
      for (final p in grammar.productions) {
        for (int i = 0; i < p.rhs.length; i++) {
          final sym = p.rhs[i];
          if (!grammar.isNonTerminal(sym)) continue;

          follow[sym] ??= {};
          final before = follow[sym]!.length;

          final beta = p.rhs.sublist(i + 1);
          final firstBeta = beta.isEmpty ? {'ε'} : firstOfSequence(beta);

          // Add FIRST(β) - {ε} to FOLLOW(sym)
          follow[sym]!.addAll(firstBeta.where((s) => s != 'ε'));

          // If β can derive ε, add FOLLOW(LHS) to FOLLOW(sym)
          if (firstBeta.contains('ε') || beta.isEmpty) {
            follow[sym]!.addAll(follow[p.lhs] ?? {});
          }

          if (follow[sym]!.length != before) changed = true;
        }
      }
    }
  }

  // ── PRINT ─────────────────────────────────────────────────────────────────

  void printFirst() {
    print('\n=== FIRST SETS ===');
    for (final nt in grammar.nonTerminals) {
      final sorted = (first[nt] ?? {}).toList()..sort();
      print('  FIRST($nt) = { ${sorted.join(', ')} }');
    }
  }

  void printFollow() {
    print('\n=== FOLLOW SETS ===');
    for (final nt in grammar.nonTerminals) {
      final sorted = (follow[nt] ?? {}).toList()..sort();
      print('  FOLLOW($nt) = { ${sorted.join(', ')} }');
    }
  }
}