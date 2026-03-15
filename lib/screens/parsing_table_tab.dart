import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';

class ParsingTableTab extends StatelessWidget {
  final AnalysisResult? result;
  const ParsingTableTab({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return _emptyState();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBanner(),
          const SizedBox(height: 20),
          if (result!.conflicts.isNotEmpty) ...[
            _conflictCard(),
            const SizedBox(height: 16),
          ],
          _tableCard(),
          const SizedBox(height: 16),
          _legendCard(),
        ],
      ),
    );
  }

  Widget _statusBanner() {
    final isLL1 = result!.isLL1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLL1 ? AppTheme.matchGreen : AppTheme.errorRed,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLL1
              ? AppTheme.accent.withOpacity(0.4)
              : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLL1 ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isLL1 ? AppTheme.accent : AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLL1
                  ? 'Grammar is LL(1) — no conflicts in the parsing table.'
                  : 'Grammar is NOT LL(1) — conflicts detected.',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isLL1 ? AppTheme.accent : AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conflictCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppTheme.error, size: 18),
              const SizedBox(width: 8),
              Text('Conflicts',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...result!.conflicts.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(c,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12, color: AppTheme.error,
                ),
              ),
            ),
          )),
        ],
      ),
    ),
  );

  Widget _tableCard() {
    final terms = result!.terminals;
    final nts   = result!.nonTerminals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.table_chart_rounded,
                    color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text('Predictive Parsing Table  M[A, a]',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(color: AppTheme.border, width: 1),
                children: [
                  // Header row
                  TableRow(
                    decoration: const BoxDecoration(color: AppTheme.surface),
                    children: [
                      _headerCell('NT'),
                      ...terms.map((t) => _headerCell(t)),
                    ],
                  ),
                  // Data rows
                  ...nts.map((nt) => TableRow(
                    children: [
                      _ntCell(nt),
                      ...terms.map((t) {
                        final entry = result!.table[nt]?[t];
                        return _entryCell(entry?.toString() ?? '');
                      }),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    color: AppTheme.surface,
    child: Text(label,
      textAlign: TextAlign.center,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecond,
      ),
    ),
  );

  Widget _ntCell(String nt) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    color: AppTheme.primaryLight,
    child: Text(nt,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary,
      ),
    ),
  );

  Widget _entryCell(String entry) {
    final hasEntry = entry.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: hasEntry ? AppTheme.matchGreen : Colors.white,
      constraints: const BoxConstraints(minWidth: 120),
      child: Text(
        hasEntry ? entry : '—',
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: hasEntry ? AppTheme.accent : AppTheme.border,
          fontWeight: hasEntry ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _legendCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to Read the Table',
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'M[A, a] = production to apply when:\n'
            '  • Non-terminal A is on top of the stack\n'
            '  • Current lookahead token is a\n\n'
            'Green cells have a production. Empty cells mean error.\n'
            'If any cell has two productions → grammar is NOT LL(1).',
            style: GoogleFonts.inter(
              fontSize: 13, color: AppTheme.textSecond, height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.table_chart_outlined, size: 48, color: AppTheme.border),
        const SizedBox(height: 12),
        Text('Run analysis first',
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecond),
        ),
      ],
    ),
  );
}