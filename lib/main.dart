import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'models/analysis_result.dart';
import 'screens/input_tab.dart';
import 'screens/left_recursion_tab.dart';
import 'screens/first_follow_tab.dart';
import 'screens/parsing_table_tab.dart';
import 'screens/parsing_trace_tab.dart';

void main() {
  runApp(const LL1App());
}

class LL1App extends StatelessWidget {
  const LL1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LL(1) Visualizer',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AnalysisResult? _result;

  static const _tabs = [
    Tab(icon: Icon(Icons.edit_note_rounded,    size: 18), text: 'Input'),
    Tab(icon: Icon(Icons.refresh_rounded,      size: 18), text: 'Left Recursion'),
    Tab(icon: Icon(Icons.calculate_outlined,   size: 18), text: 'First & Follow'),
    Tab(icon: Icon(Icons.table_chart_outlined, size: 18), text: 'Parsing Table'),
    Tab(icon: Icon(Icons.list_alt_outlined,    size: 18), text: 'Trace'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAnalyze(AnalysisResult result) {
    setState(() => _result = result);
    // Auto-navigate to first result tab
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_tree_rounded,
                color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LL(1) Visualizer',
                  style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text('Compiler Design — Syntax Analysis',
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.textSecond,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InputTab(onAnalyze: _onAnalyze),
          LeftRecursionTab(result: _result),
          FirstFollowTab(result: _result),
          ParsingTableTab(result: _result),
          ParsingTraceTab(result: _result),
        ],
      ),
    );
  }
}