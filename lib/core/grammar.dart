import '../models/production.dart';

/// Holds and parses the full grammar.
/// Supports two input formats:
///   1. "E -> E + T | T"   (alternatives on same line with |)
///   2. One production per line: "E -> E + T" then "E -> T"
class Grammar {
  List<Production> productions = [];
  Set<String> nonTerminals = {};
  Set<String> terminals = {};
  String startSymbol = '';

  // ── PARSING ───────────────────────────────────────────────────────────────

  void parse(List<String> rawLines) {
    productions = [];
    nonTerminals = {};
    terminals = {};
    int index = 0;

    // First pass — collect all non-terminals (every LHS)
    for (final line in rawLines) {
      if (!line.contains('->')) continue;
      final lhs = line.split('->')[0].trim();
      nonTerminals.add(lhs);
    }

    startSymbol = rawLines
        .firstWhere((l) => l.contains('->'))
        .split('->')[0]
        .trim();

    // Second pass — parse productions
    for (final line in rawLines) {
      if (!line.contains('->')) continue;
      final parts = line.split('->');
      final lhs = parts[0].trim();
      final rhsPart = parts[1];

      // Split on | to get alternatives
      for (final alt in rhsPart.split('|')) {
        final symbols = tokenizeRhs(alt.trim());
        productions.add(Production(lhs: lhs, rhs: symbols, index: index++));
      }
    }

    // Collect terminals
    for (final p in productions) {
      if (p.isEpsilon) continue;
      for (final sym in p.rhs) {
        if (!isNonTerminal(sym)) terminals.add(sym);
      }
    }
  }

  // ── TOKENIZER ─────────────────────────────────────────────────────────────

  /// Tokenizes a RHS string into individual symbols.
  /// Handles:
  ///   - Space-separated:  "E + T"  →  ["E", "+", "T"]
  ///   - No spaces:        "E+T"    →  ["E", "+", "T"]
  ///   - Primed NTs:       "E'"     →  ["E'"]
  ///   - Multi-char terms: "id"     →  ["id"]
  ///   - Epsilon:          "ε"      →  ["ε"]
  List<String> tokenizeRhs(String rhs) {
    if (rhs.trim() == 'ε') return ['ε'];

    final tokens = <String>[];
    int i = 0;

    while (i < rhs.length) {
      final ch = rhs[i];

      // Skip spaces
      if (ch == ' ') { i++; continue; }

      // Epsilon character
      if (ch == 'ε') { tokens.add('ε'); i++; continue; }

      // Non-terminal: starts with uppercase
      if (ch.toUpperCase() == ch && ch != ch.toLowerCase()) {
        String token = ch;
        i++;
        // Collect trailing apostrophes: E', T'', etc.
        while (i < rhs.length && rhs[i] == "'") {
          token += rhs[i];
          i++;
        }
        tokens.add(token);
        continue;
      }

      // Special single-char terminals: +, *, (, ), etc.
      if ('()[]{}+*/<>=!&|^~;:,.-'.contains(ch)) {
        tokens.add(ch);
        i++;
        continue;
      }

      // Multi-char lowercase terminal: id, num, etc.
      String token = ch;
      i++;
      while (i < rhs.length &&
             rhs[i] != ' ' &&
             rhs[i] != 'ε' &&
             rhs[i].toLowerCase() == rhs[i] &&
             !"()[]{}+*/<>=!&|^~;:,.-'".contains(rhs[i])) {
        token += rhs[i];
        i++;
      }
      tokens.add(token);
    }

    return tokens;
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  /// A symbol is a non-terminal if:
  ///   - It's in the known non-terminals set, OR
  ///   - It starts with uppercase (and optionally ends with ')
  bool isNonTerminal(String symbol) {
    if (nonTerminals.contains(symbol)) return true;
    if (symbol.isEmpty) return false;
    final base = symbol.replaceAll("'", '');
    if (base.isEmpty) return false;
    return base[0] == base[0].toUpperCase() &&
           base[0] != base[0].toLowerCase();
  }

  void printGrammar() {
    print('\n=== GRAMMAR ===');
    for (final p in productions) {
      print('  p${p.index}: $p');
    }
    print('  Non-terminals : $nonTerminals');
    print('  Terminals     : $terminals');
    print('  Start symbol  : $startSymbol');
  }
}