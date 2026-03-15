import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/analysis_result.dart';

class InputTab extends StatefulWidget {
  final void Function(AnalysisResult) onAnalyze;

  const InputTab({super.key, required this.onAnalyze});

  @override
  State<InputTab> createState() => _InputTabState();
}

class _InputTabState extends State<InputTab> {
  final _grammarController = TextEditingController(
    text: 'E -> E + T | T\nT -> T * F | F\nF -> ( E ) | id',
  );
  final _inputController = TextEditingController(text: 'id + id * id');
  String? _error;
  bool _loading = false;

  void _analyze() {
    setState(() { _error = null; _loading = true; });

    final lines = _grammarController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.contains('->'))
        .toList();

    if (lines.isEmpty) {
      setState(() {
        _error = 'Please enter at least one production.';
        _loading = false;
      });
      return;
    }

    try {
      final result = runAnalysis(lines, _inputController.text.trim());
      setState(() => _loading = false);
      widget.onAnalyze(result);
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.functions_rounded,
            title: 'Grammar Input',
            subtitle: 'Enter one or more productions. Use | for alternatives.',
          ),
          const SizedBox(height: 12),
          _grammarField(),
          const SizedBox(height: 8),
          _hint('Example: E -> E + T | T   or   E -> E + T then E -> T on next line'),
          const SizedBox(height: 24),
          _sectionHeader(
            icon: Icons.input_rounded,
            title: 'Input String',
            subtitle: 'The string to parse. Separate tokens with spaces.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputController,
            style: GoogleFonts.jetBrainsMono(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'e.g.  id + id * id',
            ),
          ),
          const SizedBox(height: 8),
          _hint('Tokens are matched against grammar terminals automatically.'),
          const SizedBox(height: 32),
          if (_error != null) ...[
            _errorBanner(_error!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_loading ? 'Analyzing...' : 'Run LL(1) Analysis'),
            ),
          ),
          const SizedBox(height: 32),
          _infoCard(),
        ],
      ),
    );
  }

  Widget _grammarField() => TextField(
    controller: _grammarController,
    maxLines: 6,
    style: GoogleFonts.jetBrainsMono(fontSize: 14),
    decoration: const InputDecoration(
      hintText: 'E -> E + T | T\nT -> T * F | F\nF -> ( E ) | id',
      alignLabelWithHint: true,
    ),
  );

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle,
              style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.textSecond,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _hint(String text) => Row(
    children: [
      const Icon(Icons.info_outline, size: 14, color: AppTheme.textSecond),
      const SizedBox(width: 6),
      Expanded(
        child: Text(text,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecond),
        ),
      ),
    ],
  );

  Widget _errorBanner(String msg) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.errorRed,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.error),
          ),
        ),
      ],
    ),
  );

  Widget _infoCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LL(1) Analysis Pipeline',
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._pipelineSteps.map((s) => _pipelineRow(s.$1, s.$2, s.$3)),
        ],
      ),
    ),
  );

  static const _pipelineSteps = [
    (Icons.refresh_rounded,    'Left Recursion Removal',   'Eliminates infinite loops in top-down parsing'),
    (Icons.calculate_outlined, 'FIRST & FOLLOW Sets',      'Computes lookahead information for each non-terminal'),
    (Icons.table_chart_outlined,'LL(1) Parsing Table',     'Builds the predictive parsing table'),
    (Icons.list_alt_outlined,  'Parsing Trace',            'Simulates the stack-based parse step by step'),
  ];

  Widget _pipelineRow(IconData icon, String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(desc,
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.textSecond,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}