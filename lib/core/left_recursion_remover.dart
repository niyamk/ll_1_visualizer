import '../models/production.dart';
import 'grammar.dart';

/// Left Recursion Removal
///
/// Handles both:
///   Direct:   A -> Aα | β   becomes   A -> βA'  /  A' -> αA' | ε
///   Indirect: A -> Bα, B -> Aβ  (substituted first, then direct removal)
///
/// Algorithm:
///   Order non-terminals as A1, A2, ..., An
///   For each Ai:
///     For each Aj where j < i:
///       Replace Ai -> Aj γ  with  Ai -> δ1 γ | δ2 γ | ...
///       (where Aj -> δ1 | δ2 | ... are current productions)
///     Then remove direct left recursion for Ai
class LeftRecursionRemover {
  final Grammar grammar;
  List<Production> result = [];
  Set<String> newNonTerminals = {};
  List<String> removalSteps = []; // for display

  LeftRecursionRemover(this.grammar);

  void remove() {
    result = [];
    newNonTerminals = {};
    removalSteps = [];

    // Work with a mutable copy of productions grouped by LHS
    final Map<String, List<List<String>>> prods = {};
    final List<String> order = [];

    for (final p in grammar.productions) {
      if (!order.contains(p.lhs)) order.add(p.lhs);
      prods.putIfAbsent(p.lhs, () => []).add(List.from(p.rhs));
    }

    for (int i = 0; i < order.length; i++) {
      final ai = order[i];

      // Step 1: eliminate indirect left recursion
      // Replace Ai -> Aj γ with Ai -> (all Aj alternatives) γ
      for (int j = 0; j < i; j++) {
        final aj = order[j];
        final newAlts = <List<String>>[];

        for (final alt in prods[ai]!) {
          if (alt.isNotEmpty && alt[0] == aj) {
            // Replace Ai -> Aj γ with Ai -> δk γ for each Aj -> δk
            final gamma = alt.sublist(1);
            for (final delta in prods[aj]!) {
              if (delta.length == 1 && delta[0] == 'ε') {
                newAlts.add(gamma.isEmpty ? ['ε'] : gamma);
              } else {
                newAlts.add([...delta, ...gamma]);
              }
            }
            removalSteps.add(
              'Substituted $aj into $ai: $ai -> ${alt.join(' ')} '
              'becomes ${prods[aj]!.map((d) => [...d, ...alt.sublist(1)].join(' ')).join(' | ')}',
            );
          } else {
            newAlts.add(alt);
          }
        }
        prods[ai] = newAlts;
      }

      // Step 2: remove direct left recursion for Ai
      final recursive = prods[ai]!.where((a) => a.isNotEmpty && a[0] == ai).toList();
      final nonRecursive = prods[ai]!.where((a) => a.isEmpty || a[0] != ai).toList();

      if (recursive.isEmpty) continue; // no direct LR, nothing to do

      removalSteps.add('Removing direct left recursion for $ai');

      // Ai -> βA'  for each non-recursive alternative β
      // A' -> αA' | ε  for each recursive alternative Aiα
      final prime = _makePrime(ai, prods.keys.toSet()..addAll(newNonTerminals));
      newNonTerminals.add(prime);

      prods[ai] = nonRecursive.map((beta) {
        if (beta.length == 1 && beta[0] == 'ε') return [prime];
        return [...beta, prime];
      }).toList();

      prods[prime] = [
        ...recursive.map((alpha) => [...alpha.sublist(1), prime]),
        ['ε'],
      ];
      order.add(prime);
    }

    // Rebuild flat production list
    int index = 0;
    for (final lhs in order) {
      for (final rhs in prods[lhs] ?? []) {
        result.add(Production(lhs: lhs, rhs: rhs, index: index++));
      }
    }

    // Update grammar
    grammar.productions = result;
    grammar.nonTerminals.addAll(newNonTerminals);
    for (final p in result) {
      if (p.isEpsilon) continue;
      for (final sym in p.rhs) {
        if (!grammar.isNonTerminal(sym)) grammar.terminals.add(sym);
      }
    }
  }

  /// Creates a primed version of symbol that doesn't already exist.
  /// E -> E' -> E'' etc.
  String _makePrime(String symbol, Set<String> existing) {
    String candidate = "$symbol'";
    while (existing.contains(candidate)) candidate += "'";
    return candidate;
  }

  void printResult() {
    print('\n=== AFTER LEFT RECURSION REMOVAL ===');
    if (removalSteps.isEmpty) {
      print('  No left recursion found — grammar unchanged.');
    } else {
      print('  Steps:');
      for (final step in removalSteps) print('    • $step');
      print('\n  Resulting productions:');
      for (final p in result) print('    $p');
    }
  }
}