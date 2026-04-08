import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';
import '../core/first_follow.dart';

class FirstFollowTab extends StatelessWidget {
  final AnalysisResult? result;
  const FirstFollowTab({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return _emptyState();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setCard(
            title: 'FIRST Sets',
            subtitle: 'Terminals that can begin a string derived from each non-terminal',
            icon: Icons.first_page_rounded,
            color: AppTheme.primaryLight,
            iconColor: AppTheme.primary,
            sets: result!.first,
            nts: result!.nonTerminals,
            setType: 'FIRST',
            result: result,
          ),
          const SizedBox(height: 16),
          _setCard(
            title: 'FOLLOW Sets',
            subtitle: 'Terminals that can appear immediately after each non-terminal',
            icon: Icons.last_page_rounded,
            color: AppTheme.matchGreen,
            iconColor: AppTheme.accent,
            sets: result!.follow,
            nts: result!.nonTerminals,
            setType: 'FOLLOW',
            result: result,
          ),
          const SizedBox(height: 20),
          _rulesCard(),
        ],
      ),
    );
  }

  Widget _setCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Map<String, Set<String>> sets,
    required List<String> nts,
    required String setType,
    required AnalysisResult? result,
  }) => Card(
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
                  color: color, borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textSecond,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Table header
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _tableHeader(),
                const Divider(height: 1),
                ...nts.asMap().entries.map((e) {
                  final explanation = setType == 'FIRST'
                      ? result?.firstExplanations[e.value]
                      : result?.followExplanations[e.value];
                  return Column(
                    children: [
                      _accordionRow(
                        nt: e.value,
                        tokens: (sets[e.value] ?? {}).toList()..sort(),
                        isEven: e.key.isEven,
                        color: color,
                        tokenColor: iconColor,
                        explanation: explanation,
                      ),
                      if (e.key < nts.length - 1) const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _tableHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text('NT',
            style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: AppTheme.textSecond,
            ),
          ),
        ),
        Text('Set',
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: AppTheme.textSecond,
          ),
        ),
      ],
    ),
  );

  Widget _accordionRow({
    required String nt,
    required List<String> tokens,
    required bool isEven,
    required Color color,
    required Color tokenColor,
    required SetExplanation? explanation,
  }) => Container(
    decoration: const BoxDecoration(),
    clipBehavior: Clip.hardEdge,
    child: Material(
      color: Colors.transparent,
      child: ExpansionTile(
        collapsedBackgroundColor: isEven ? Colors.white : AppTheme.surface,
        backgroundColor: color.withOpacity(0.3),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        title: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(nt,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: tokens.isEmpty
                  ? Text('{ }',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13, color: AppTheme.textSecond,
                      ),
                    )
                  : Wrap(
                      spacing: 6, runSpacing: 4,
                      children: tokens
                          .map((t) => _chip(t, color, tokenColor))
                          .toList(),
                    ),
            ),
          ],
        ),
        subtitle: Text('tap to see computation steps',
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecond),
        ),
        children: [
          if (explanation != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: explanation.steps.map((step) {
                  final isHeader = !step.startsWith(' ') && step.endsWith(':');
                  final isEmpty  = step.trim().isEmpty;
                  if (isEmpty) return const SizedBox(height: 6);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(step,
                      style: isHeader
                          ? GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: tokenColor,
                            )
                          : GoogleFonts.jetBrainsMono(
                              fontSize: 12, color: AppTheme.textPrimary,
                            ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('No explanation available.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecond),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: fg.withOpacity(0.3)),
    ),
    child: Text(label,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.w600, color: fg,
      ),
    ),
  );

  Widget _rulesCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Computation Rules',
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _rule('FIRST',
            'For A → a…: add a to FIRST(A)\n'
            'For A → Bβ: add FIRST(B)−{ε} to FIRST(A); if ε∈FIRST(B), also add FIRST(β)\n'
            'For A → ε: add ε to FIRST(A)',
          ),
          const SizedBox(height: 8),
          _rule('FOLLOW',
            'Add \$ to FOLLOW(start symbol)\n'
            'For A → αBβ: add FIRST(β)−{ε} to FOLLOW(B)\n'
            'If ε∈FIRST(β) or β=empty: add FOLLOW(A) to FOLLOW(B)',
          ),
        ],
      ),
    ),
  );

  Widget _rule(String label, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text,
          style: GoogleFonts.inter(
            fontSize: 12, color: AppTheme.textSecond, height: 1.6,
          ),
        ),
      ),
    ],
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calculate_outlined, size: 48, color: AppTheme.border),
        const SizedBox(height: 12),
        Text('Run analysis first',
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecond),
        ),
      ],
    ),
  );
}

