/// Represents one grammar production rule.
/// e.g.  E -> E + T   →  lhs = "E",  rhs = ["E", "+", "T"]
/// e.g.  A -> ε        →  lhs = "A",  rhs = ["ε"]
class Production {
  final String lhs;
  final List<String> rhs;
  final int index;

  Production({required this.lhs, required this.rhs, required this.index});

  bool get isEpsilon => rhs.length == 1 && rhs[0] == 'ε';

  @override
  String toString() => '$lhs -> ${rhs.join(' ')}';

  @override
  bool operator ==(Object other) =>
      other is Production && other.lhs == lhs && other.index == index;

  @override
  int get hashCode => Object.hash(lhs, index);
}