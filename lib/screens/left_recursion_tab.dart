import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';

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
            _productionCard(
              title: 'After Removal',
              icon: Icons.check_circle_outline_rounded,
              prods: result!.cleanedProductions.map((p) => p.toString()).toList(),
              color: AppTheme.matchGreen,
              iconColor: AppTheme.accent,
            ),
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