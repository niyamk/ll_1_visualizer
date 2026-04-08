import 'grammar.dart';

/// Stores step-by-step reasoning for how FIRST or FOLLOW
/// was computed for one non-terminal.
class SetExplanation {
  final String nonTerminal;
  final List<String> steps;
  final String setType; // 'FIRST' or 'FOLLOW'

  SetExplanation({
    required this.nonTerminal,
    required this.steps,
    required this.setType,
  });
}

/// Computes FIRST and FOLLOW sets for all non-terminals.
///
/// FIRST(X)  = set of terminals that can begin any string derived from X
/// FOLLOW(A) = set of terminals that can appear immediately after A
class FirstFollow {
  final Grammar grammar;
  Map<String, Set<String>> first = {};
  Map<String, Set<String>> follow = {};
  Map<String, SetExplanation> firstExplanations = {};
  Map<String, SetExplanation> followExplanations = {};

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

    // Build explanations for each non-terminal
    for (final nt in grammar.nonTerminals) {
      final steps = <String>[];
      final relevantProds = grammar.productions.where((p) => p.lhs == nt).toList();

      steps.add('Productions for $nt:');
      for (final p in relevantProds) {
        steps.add('  $p');
      }
      steps.add('');
      steps.add('Computing FIRST($nt):');

      for (final p in relevantProds) {
        if (p.isEpsilon) {
          steps.add('  $p  →  ε production, add ε to FIRST($nt)');
          continue;
        }
        final firstSym = p.rhs[0];
        if (!grammar.isNonTerminal(firstSym)) {
          steps.add('  $p  →  starts with terminal "$firstSym", add "$firstSym" to FIRST($nt)');
        } else {
          final f = first[firstSym] ?? {};
          steps.add('  $p  →  starts with non-terminal $firstSym');
          steps.add('         FIRST($firstSym) = { ${f.join(', ')} }');
          steps.add('         Add FIRST($firstSym) - {ε} to FIRST($nt)');
          if (f.contains('ε')) {
            if (p.rhs.length > 1) {
              steps.add('         ε ∈ FIRST($firstSym), so also look at next symbol: ${p.rhs[1]}');
            } else {
              steps.add('         ε ∈ FIRST($firstSym) and no more symbols, so add ε to FIRST($nt)');
            }
          }
        }
      }

      final result = first[nt] ?? {};
      steps.add('');
      steps.add('Result: FIRST($nt) = { ${result.toList()..sort()..join(', ')} }');

      firstExplanations[nt] = SetExplanation(
        nonTerminal: nt,
        steps: steps,
        setType: 'FIRST',
      );
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
          final firstBeta = firstOfSequence(beta);

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

    // Build explanations for each non-terminal
    for (final nt in grammar.nonTerminals) {
      final steps = <String>[];

      if (nt == grammar.startSymbol) {
        steps.add('$nt is the start symbol → add \$ to FOLLOW($nt)');
        steps.add('');
      }

      steps.add('Scanning all productions for occurrences of $nt:');

      for (final p in grammar.productions) {
        for (int i = 0; i < p.rhs.length; i++) {
          if (p.rhs[i] != nt) continue;

          final beta = p.rhs.sublist(i + 1);
          steps.add('');
          steps.add('  Found in: $p');

          if (beta.isEmpty) {
            steps.add('  $nt is at the end → add FOLLOW(${p.lhs}) to FOLLOW($nt)');
            steps.add('  FOLLOW(${p.lhs}) = { ${(follow[p.lhs] ?? {}).join(', ')} }');
          } else {
            final firstBeta = firstOfSequence(beta);
            steps.add('  Followed by: ${beta.join(' ')}');
            steps.add('  FIRST(${beta.join(' ')}) = { ${firstBeta.join(', ')} }');
            steps.add('  Add FIRST(${beta.join(' ')}) - {ε} to FOLLOW($nt)');
            if (firstBeta.contains('ε')) {
              steps.add('  ε ∈ FIRST(${beta.join(' ')}) → also add FOLLOW(${p.lhs}) to FOLLOW($nt)');
              steps.add('  FOLLOW(${p.lhs}) = { ${(follow[p.lhs] ?? {}).join(', ')} }');
            }
          }
        }
      }

      final result = follow[nt] ?? {};
      steps.add('');
      steps.add('Result: FOLLOW($nt) = { ${result.toList()..sort()..join(', ')} }');

      followExplanations[nt] = SetExplanation(
        nonTerminal: nt,
        steps: steps,
        setType: 'FOLLOW',
      );
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

