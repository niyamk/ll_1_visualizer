import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';
import '../core/left_recursion_remover.dart';

class LeftRecursionTab extends StatelessWidget {
  final AnalysisResult? result;
  const LeftRecursionTab({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return _emptyState();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBanner(result!.hadLeftRecursion),
          const SizedBox(height: 20),
          _productionCard(
            title: 'Original Grammar',
            icon: Icons.article_outlined,
            prods: result!.originalProductions.map((p) => p.toString()).toList(),
            color: AppTheme.primaryLight,
            iconColor: AppTheme.primary,
          ),
          if (result!.hadLeftRecursion) ...[
            const SizedBox(height: 16),
            _stepsCard(),
            const SizedBox(height: 16),
            _accordionCard(),
          ],
          const SizedBox(height: 20),
          _theoryBox(),
        ],
      ),
    );
  }

  Widget _statusBanner(bool hadLR) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: hadLR ? AppTheme.highlight : AppTheme.matchGreen,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: hadLR
            ? AppTheme.warning.withOpacity(0.4)
            : AppTheme.accent.withOpacity(0.4),
      ),
    ),
    child: Row(
      children: [
        Icon(
          hadLR ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
          color: hadLR ? AppTheme.warning : AppTheme.accent,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hadLR
                ? 'Left recursion detected and removed successfully.'
                : 'No left recursion found — grammar is already suitable.',
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: hadLR ? AppTheme.warning : AppTheme.accent,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _productionCard({
    required String title,
    required IconData icon,
    required List<String> prods,
    required Color color,
    required Color iconColor,
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
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prods.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(p,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13, color: AppTheme.textPrimary,
                ),
              ),
            ),
          )),
        ],
      ),
    ),
  );

  Widget _accordionCard() => Card(
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
                  color: AppTheme.matchGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppTheme.accent, size: 16),
              ),
              const SizedBox(width: 10),
              Text('After Left Recursion Removal',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //   decoration: BoxDecoration(
              //     color: AppTheme.primaryLight,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Text('tap to expand',
              //     style: GoogleFonts.inter(
              //       fontSize: 11, color: AppTheme.primary,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          ...result!.lrExplanations.map((exp) => _lrAccordionItem(exp)),
          // Also show productions that had no left recursion (no explanation)
          ...result!.cleanedProductions
              .where((p) => !result!.lrExplanations
                  .any((e) => e.resultProductions.contains(p.toString())))
              .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(p.toString(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              )),
        ],
      ),
    ),
  );

  Widget _lrAccordionItem(LRExplanation exp) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          collapsedBackgroundColor: AppTheme.surface,
          backgroundColor: AppTheme.primaryLight,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(exp.nonTerminal,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            exp.resultProductions.take(2).join('  |  ') +
                (exp.resultProductions.length > 2 ? '  ...' : ''),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12, color: AppTheme.primary,
            ),
          ),
          subtitle: Text('tap to see how this was derived',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecond),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exp.steps.map((step) {
                  final isHeader = !step.startsWith(' ') && step.endsWith(':');
                  final isEmpty  = step.trim().isEmpty;
                  if (isEmpty) return const SizedBox(height: 6);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(step,
                      style: isHeader
                          ? GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            )
                          : GoogleFonts.jetBrainsMono(
                              fontSize: 12, color: AppTheme.textPrimary,
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _stepsCard() => Card(
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
                  color: AppTheme.highlight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                  color: AppTheme.warning, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Removal Steps',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result!.lrSteps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text('${e.key + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.value,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ),
  );

  Widget _theoryBox() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why Remove Left Recursion?',
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A top-down parser expanding A → Aα would call itself '
            'infinitely before consuming any input — causing an infinite loop. '
            '\n\nThe fix:\n'
            '  A → Aα | β    becomes    A → βA\'    and    A\' → αA\' | ε',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecond, height: 1.6),
          ),
        ],
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.refresh_rounded, size: 48, color: AppTheme.border),
        const SizedBox(height: 12),
        Text('Run analysis first',
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecond),
        ),
        const SizedBox(height: 4),
        Text('Go to the Input tab and click "Run LL(1) Analysis"',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecond),
        ),
      ],
    ),
  );
}

