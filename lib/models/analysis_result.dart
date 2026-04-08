import '../models/production.dart';
import '../models/parse_step.dart';
import '../core/grammar.dart';
import '../core/left_recursion_remover.dart';
import '../core/first_follow.dart';
import '../core/ll1_table.dart';
import '../core/ll1_parser.dart';

/// Holds every result produced by the LL(1) pipeline.
/// Passed down to every tab screen.
class AnalysisResult {
  // ── INPUT ──────────────────────────────────────────────────────────────────
  final List<String> rawProductions;
  final String inputString;

  // ── STEP 1: Original grammar ───────────────────────────────────────────────
  final List<Production> originalProductions;

  // ── STEP 2: Left recursion removal ────────────────────────────────────────
  final List<Production> cleanedProductions;
  final List<String> lrSteps;
  final bool hadLeftRecursion;
  // Add these fields to the class
  final List<LRExplanation> lrExplanations;
  final Map<String, SetExplanation> firstExplanations;
  final Map<String, SetExplanation> followExplanations;

  // ── STEP 3: FIRST & FOLLOW ─────────────────────────────────────────────────
  final Map<String, Set<String>> first;
  final Map<String, Set<String>> follow;
  final List<String> nonTerminals;
  final List<String> terminals;

  // ── STEP 4: Parsing table ─────────────────────────────────────────────────
  final Map<String, Map<String, Production>> table;
  final bool isLL1;
  final List<String> conflicts;

  // ── STEP 5: Parsing trace ─────────────────────────────────────────────────
  final List<ParseStep> parseSteps;
  final bool accepted;

  AnalysisResult({
    required this.rawProductions,
    required this.inputString,
    required this.originalProductions,
    required this.cleanedProductions,
    required this.lrSteps,
    required this.hadLeftRecursion,
    required this.lrExplanations,
    required this.firstExplanations,
    required this.followExplanations,
    required this.first,
    required this.follow,
    required this.nonTerminals,
    required this.terminals,
    required this.table,
    required this.isLL1,
    required this.conflicts,
    required this.parseSteps,
    required this.accepted,
  });
}

/// Runs the full LL(1) pipeline and returns an AnalysisResult.
AnalysisResult runAnalysis(List<String> rawProductions, String inputString) {
  // Step 1: Parse grammar
  final grammar = Grammar();
  grammar.parse(rawProductions);
  final originalProductions = List<Production>.from(grammar.productions);

  // Step 2: Remove left recursion
  final lrr = LeftRecursionRemover(grammar);
  lrr.remove();

  // Step 3: FIRST & FOLLOW
  final ff = FirstFollow(grammar);
  ff.compute();

  // Step 4: Parsing table
  final table = LL1Table(grammar, ff);
  table.build();

  // Step 5: Parse input string
  List<ParseStep> steps = [];
  bool accepted = false;
  if (!table.hasConflict) {
    final parser = LL1Parser(grammar, table);
    accepted = parser.parse(inputString);
    steps = parser.steps;
  }

  return AnalysisResult(
    rawProductions:      rawProductions,
    inputString:         inputString,
    originalProductions: originalProductions,
    cleanedProductions:  List.from(grammar.productions),
    lrSteps:             lrr.removalSteps,
    hadLeftRecursion:    lrr.removalSteps.isNotEmpty,
    lrExplanations:      lrr.explanations,
    firstExplanations:   ff.firstExplanations,
    followExplanations:  ff.followExplanations,
    first:               ff.first,
    follow:              ff.follow,
    nonTerminals:        grammar.nonTerminals
                             .where((nt) => ff.follow.containsKey(nt))
                             .toList()..sort(),
    terminals:           [...grammar.terminals.toList()..sort(), r'$'],
    table:               table.table,
    isLL1:               !table.hasConflict,
    conflicts:           table.conflicts,
    parseSteps:          steps,
    accepted:            accepted,
  );
}

