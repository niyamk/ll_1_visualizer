import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';
import '../models/parse_step.dart';

class ParsingTraceTab extends StatelessWidget {
  final AnalysisResult? result;
  const ParsingTraceTab({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return _emptyState();
    if (!result!.isLL1) return _notLL1State();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _resultBanner(),
          const SizedBox(height: 20),
          _inputRow(),
          const SizedBox(height: 16),
          _traceCard(),
          const SizedBox(height: 16),
          _legendCard(),
        ],
      ),
    );
  }

  Widget _resultBanner() {
    final accepted = result!.accepted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accepted ? AppTheme.matchGreen : AppTheme.errorRed,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accepted ? AppTheme.accent.withOpacity(0.4) : AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            accepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: accepted ? AppTheme.accent : AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              accepted
                  ? 'String "${result!.inputString}" is ACCEPTED by the grammar.'
                  : 'String "${result!.inputString}" is REJECTED — parsing error.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accepted ? AppTheme.accent : AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputRow() => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _infoChip('Input', result!.inputString, AppTheme.primaryLight, AppTheme.primary),
          const SizedBox(width: 12),
          _infoChip('Steps', '${result!.parseSteps.length}', AppTheme.matchGreen, AppTheme.accent),
        ],
      ),
    ),
  );

  Widget _infoChip(String label, String value, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: fg, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(fontSize: 14, color: fg, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _traceCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.list_alt_rounded, color: AppTheme.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Step-by-Step Trace',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppTheme.surface),
              dataRowMinHeight: 42,
              dataRowMaxHeight: 60,
              columnSpacing: 16,
              horizontalMargin: 12,
              border: TableBorder.all(color: AppTheme.border, width: 1),
              columns: [_col('#'), _col('Stack'), _col('Input'), _col('Action')],
              rows: result!.parseSteps.asMap().entries.map((e) {
                return _traceRow(e.key + 1, e.value);
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );

  DataColumn _col(String label) => DataColumn(
    label: Text(
      label,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecond),
    ),
  );

  DataRow _traceRow(int index, ParseStep step) {
    final action = step.action;
    Color rowColor;
    Color actionColor;

    if (action.contains('ACCEPT')) {
      rowColor = AppTheme.matchGreen;
      actionColor = AppTheme.accent;
    } else if (action.contains('ERROR')) {
      rowColor = AppTheme.errorRed;
      actionColor = AppTheme.error;
    } else if (action.startsWith('Match')) {
      rowColor = AppTheme.applyBlue;
      actionColor = AppTheme.primary;
    } else {
      rowColor = Colors.white;
      actionColor = AppTheme.textPrimary;
    }

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(
          Text(
            '$index',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecond, fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(step.stack.join(' '), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.textPrimary)),
        ),
        DataCell(
          Text(step.input.join(' '), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.textPrimary)),
        ),
        DataCell(
          Text(
            action,
            style: GoogleFonts.inter(fontSize: 12, color: actionColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _legendCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Legend',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          _legendRow(
            AppTheme.applyBlue,
            AppTheme.primary,
            'Match',
            'Terminal on stack matches lookahead — pop & advance',
          ),
          _legendRow(Colors.white, AppTheme.textPrimary, 'Apply', 'Expand non-terminal using table entry'),
          _legendRow(AppTheme.matchGreen, AppTheme.accent, 'Accept', 'Stack and input both empty — string accepted'),
          _legendRow(AppTheme.errorRed, AppTheme.error, 'Error', 'No table entry or terminal mismatch'),
        ],
      ),
    ),
  );

  Widget _legendRow(Color bg, Color fg, String label, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppTheme.border),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label — ',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
        ),
        Expanded(
          child: Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecond)),
        ),
      ],
    ),
  );

  Widget _notLL1State() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block_rounded, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text(
            'Cannot parse — grammar is not LL(1)',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Check the Parsing Table tab for conflicts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecond),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.list_alt_outlined, size: 48, color: AppTheme.border),
        const SizedBox(height: 12),
        Text('Run analysis first', style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecond)),
      ],
    ),
  );
}
