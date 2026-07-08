import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ============= REPORTS SCREEN =============
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Analysis', 'Treatment', 'Progress', 'Compliance'];

  final List<_ReportItem> _reports = [
    _ReportItem(
      title: 'Comprehensive STL Analysis',
      subtitle: 'Case #2024-001 · Dr. Sarah Johnson',
      date: 'Jun 18, 2026',
      type: 'Analysis',
      status: 'Complete',
      statusColor: AppColors.success,
      effectivenessScore: 87,
      predictability: 82,
      attachments: 24,
      icon: Icons.biotech_rounded,
      iconGradient: AppGradients.primaryGradient,
    ),
    _ReportItem(
      title: 'Treatment Progress Report',
      subtitle: 'Patient: Alex Thompson',
      date: 'Jun 15, 2026',
      type: 'Progress',
      status: 'Review',
      statusColor: AppColors.warning,
      effectivenessScore: 74,
      predictability: 68,
      attachments: 18,
      icon: Icons.timeline_rounded,
      iconGradient: AppGradients.tealGradient,
    ),
    _ReportItem(
      title: 'Attachment Placement Validation',
      subtitle: 'Case #2024-003 · Post-treatment',
      date: 'Jun 10, 2026',
      type: 'Compliance',
      status: 'Complete',
      statusColor: AppColors.success,
      effectivenessScore: 93,
      predictability: 91,
      attachments: 28,
      icon: Icons.verified_rounded,
      iconGradient: AppGradients.successGradient,
    ),
    _ReportItem(
      title: 'Risk Assessment Summary',
      subtitle: 'Multi-case: 12 patients',
      date: 'Jun 5, 2026',
      type: 'Analysis',
      status: 'Draft',
      statusColor: AppColors.info,
      effectivenessScore: 79,
      predictability: 75,
      attachments: 156,
      icon: Icons.shield_rounded,
      iconGradient: AppGradients.purpleGradient,
    ),
    _ReportItem(
      title: 'Monthly Clinic Summary',
      subtitle: 'June 2026 · All doctors',
      date: 'Jun 1, 2026',
      type: 'Treatment',
      status: 'Complete',
      statusColor: AppColors.success,
      effectivenessScore: 85,
      predictability: 80,
      attachments: 320,
      icon: Icons.bar_chart_rounded,
      iconGradient: AppGradients.warningGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_ReportItem> get _filtered => _selectedFilter == 'All'
      ? _reports
      : _reports.where((r) => r.type == _selectedFilter).toList();

  void _showExportSheet(_ReportItem report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomPad = MediaQuery.of(ctx).viewInsets.bottom +
            MediaQuery.of(ctx).padding.bottom;
        return _ExportSheet(report: report, bottomPad: bottomPad);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Reports & Analytics',
                        style: TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                        )),
                    const SizedBox(height: 4),
                    Text('${_reports.length} reports · Last updated today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12,
                          fontFamily: 'Poppins',
                        )),
                  ],
                ),
              ),
              title: null,
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondaryLight,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Reports'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ReportsTab(
              reports: _filtered,
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterChanged: (f) => setState(() => _selectedFilter = f),
              onExport: _showExportSheet,
            ),
            const _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Reports list tab
class _ReportsTab extends StatelessWidget {
  final List<_ReportItem> reports;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<_ReportItem> onExport;

  const _ReportsTab({
    required this.reports, required this.filters,
    required this.selectedFilter, required this.onFilterChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary cards
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            _SummaryChip(label: 'Total', value: '${reports.length}', color: AppColors.primary),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Complete', value: '3', color: AppColors.success),
            const SizedBox(width: 10),
            _SummaryChip(label: 'In Review', value: '1', color: AppColors.warning),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Draft', value: '1', color: AppColors.info),
          ]),
        ),

        // Filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = filters[i];
              final active = f == selectedFilter;
              return GestureDetector(
                onTap: () => onFilterChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(f,
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500, fontSize: 12,
                      )),
                ),
              );
            },
          ),
        ),

        // Report cards
        Expanded(
          child: reports.isEmpty
              ? const Center(child: Text('No reports for this filter'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: reports.length,
                  itemBuilder: (_, i) => _ReportCard(
                    report: reports[i],
                    onExport: () => onExport(reports[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Individual report card
class _ReportCard extends StatelessWidget {
  final _ReportItem report;
  final VoidCallback onExport;
  const _ReportCard({required this.report, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: report.iconGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(report.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title,
                          style: const TextStyle(
                            fontSize: 14, fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text(report.subtitle,
                          style: const TextStyle(
                            fontSize: 11, fontFamily: 'Poppins',
                            color: AppColors.textTertiary,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: report.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(report.status,
                      style: TextStyle(
                        color: report.statusColor, fontSize: 10,
                        fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
          ),

          // Metrics row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Metric(label: 'Effectiveness', value: '${report.effectivenessScore}%',
                    color: report.effectivenessScore >= 85 ? AppColors.success : AppColors.warning),
                _VertDivider(),
                _Metric(label: 'Predictability', value: '${report.predictability}%',
                    color: report.predictability >= 80 ? AppColors.success : AppColors.warning),
                _VertDivider(),
                _Metric(label: 'Attachments', value: '${report.attachments}',
                    color: AppColors.primary),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(report.date,
                    style: const TextStyle(
                      fontSize: 11, fontFamily: 'Poppins',
                      color: AppColors.textTertiary,
                    )),
                const Spacer(),
                // View button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                // Export button
                ElevatedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.ios_share_rounded, size: 14),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Analytics tab
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall stats
          Row(children: [
            Expanded(child: _AnalyticCard(
              title: 'Avg Effectiveness', value: '84%',
              trend: '+3%', positive: true, icon: Icons.trending_up_rounded,
              gradient: AppGradients.primaryGradient,
            )),
            const SizedBox(width: 12),
            Expanded(child: _AnalyticCard(
              title: 'Avg Predictability', value: '79%',
              trend: '+5%', positive: true, icon: Icons.auto_graph_rounded,
              gradient: AppGradients.tealGradient,
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _AnalyticCard(
              title: 'Cases Analyzed', value: '47',
              trend: '+12 this month', positive: true, icon: Icons.cases_rounded,
              gradient: AppGradients.purpleGradient,
            )),
            const SizedBox(width: 12),
            Expanded(child: _AnalyticCard(
              title: 'High-Risk Cases', value: '6',
              trend: '-2 this month', positive: true, icon: Icons.warning_amber_rounded,
              gradient: AppGradients.warningGradient,
            )),
          ]),

          const SizedBox(height: 20),

          // Monthly trend - visual bar chart
          const _SectionTitle('Case Volume — Last 6 Months'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Bar(label: 'Jan', height: 60, value: 8),
                  _Bar(label: 'Feb', height: 80, value: 11),
                  _Bar(label: 'Mar', height: 100, value: 14),
                  _Bar(label: 'Apr', height: 75, value: 10),
                  _Bar(label: 'May', height: 115, value: 16),
                  _Bar(label: 'Jun', height: 130, value: 18, isActive: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 6),
                const Text('Cases analyzed per month',
                    style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppColors.textTertiary)),
              ]),
            ]),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Treatment Type Distribution'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _DistributionRow(label: 'Aligner Attachment', percent: 0.62, color: AppColors.primary),
              const SizedBox(height: 10),
              _DistributionRow(label: 'Fixed Braces', percent: 0.23, color: AppColors.secondary),
              const SizedBox(height: 10),
              _DistributionRow(label: 'Retainer Tracking', percent: 0.15, color: AppColors.accent),
            ]),
          ),

          const SizedBox(height: 20),
          const _SectionTitle('Recent Activity'),
          const SizedBox(height: 12),
          ..._activityItems.map((a) => _ActivityRow(item: a)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static const _activityItems = [
    _ActivityData('STL Analysis completed', 'Case #2024-001 · 87% effectiveness', AppColors.success, Icons.check_circle_rounded),
    _ActivityData('New report generated', 'Monthly summary exported as PDF', AppColors.info, Icons.picture_as_pdf_rounded),
    _ActivityData('Risk flag raised', 'Case #2024-007 · Root resorption concern', AppColors.error, Icons.flag_rounded),
    _ActivityData('Treatment validated', 'Case #2024-003 · 93% accuracy achieved', AppColors.success, Icons.verified_rounded),
  ];
}

// ── Export bottom sheet
class _ExportSheet extends StatelessWidget {
  final _ReportItem report;
  final double bottomPad;
  const _ExportSheet({required this.report, this.bottomPad = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Export Report', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            fontFamily: 'Poppins', color: AppColors.textPrimary,
          )),
          const SizedBox(height: 6),
          Text(report.title,
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppColors.textTertiary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          _ExportOption(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Export as PDF',
            description: 'Full clinical report with charts',
            color: const Color(0xFFE53E3E),
            onTap: () => _doExport(context, 'PDF export started'),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.table_chart_rounded,
            label: 'Export as CSV',
            description: 'Spreadsheet-ready data',
            color: AppColors.success,
            onTap: () => _doExport(context, 'CSV export started'),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.code_rounded,
            label: 'Export as JSON',
            description: 'Raw analysis data for integration',
            color: AppColors.primary,
            onTap: () => _doExport(context, 'JSON export started'),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.share_rounded,
            label: 'Share with Patient',
            description: 'Send simplified report via email',
            color: AppColors.accent,
            onTap: () => _doExport(context, 'Share link copied'),
          ),
        ],
      ),
    );
  }

  void _doExport(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const _ExportOption({required this.icon, required this.label, required this.description, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: color, fontSize: 13)),
            Text(description, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.5)),
        ]),
      ),
    );
  }
}

// ── Shared data + widget helpers

class _ReportItem {
  final String title, subtitle, date, type, status;
  final Color statusColor;
  final int effectivenessScore, predictability, attachments;
  final IconData icon;
  final Gradient iconGradient;
  const _ReportItem({
    required this.title, required this.subtitle, required this.date,
    required this.type, required this.status, required this.statusColor,
    required this.effectivenessScore, required this.predictability,
    required this.attachments, required this.icon, required this.iconGradient,
  });
}

class _ActivityData {
  final String title, subtitle;
  final Color color;
  final IconData icon;
  const _ActivityData(this.title, this.subtitle, this.color, this.icon);
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 16, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textTertiary)),
    ]),
  ));
}

class _Metric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Metric({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 15, color: color)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textTertiary)),
  ]);
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: AppColors.border);
}

class _AnalyticCard extends StatelessWidget {
  final String title, value, trend;
  final bool positive;
  final IconData icon;
  final Gradient gradient;
  const _AnalyticCard({required this.title, required this.value, required this.trend,
    required this.positive, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: Colors.white70, size: 18),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(trend, style: const TextStyle(fontSize: 9, fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(title, style: TextStyle(fontSize: 10, fontFamily: 'Poppins', color: Colors.white.withOpacity(0.75))),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
          fontSize: 15, color: AppColors.textPrimary));
}

class _Bar extends StatelessWidget {
  final String label;
  final double height;
  final int value;
  final bool isActive;
  const _Bar({required this.label, required this.height, required this.value, this.isActive = false});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (isActive)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
          child: Text('$value', style: const TextStyle(fontSize: 9, fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      const SizedBox(height: 4),
      Container(
        width: 32, height: height,
        decoration: BoxDecoration(
          gradient: isActive ? AppGradients.primaryGradient : LinearGradient(
            colors: [AppColors.primaryLight.withOpacity(0.3), AppColors.primaryLight.withOpacity(0.15)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(
        fontSize: 10, fontFamily: 'Poppins',
        color: isActive ? AppColors.primary : AppColors.textTertiary,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
      )),
    ],
  );
}

class _DistributionRow extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _DistributionRow({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text('${(percent * 100).round()}%', style: TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: percent, minHeight: 7,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ],
  );
}

class _ActivityRow extends StatelessWidget {
  final _ActivityData item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: item.color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(item.icon, color: item.color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
        Text(item.subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textTertiary)),
      ])),
    ]),
  );
}

// ============= ATTACHMENT DETECTION SCREEN =============
class AttachmentDetectionScreen extends StatelessWidget {
  const AttachmentDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Attachment Detection'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Detection Summary', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Column(children: [Text('24', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)), Text('Detected', style: theme.textTheme.bodySmall)]),
                Column(children: [Text('92.5%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)), Text('Avg Confidence', style: theme.textTheme.bodySmall)]),
              ]),
            ]))),
            const SizedBox(height: 20),
            Text('Detected Attachments', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (int i = 1; i <= 6; i++)
              Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('T$i', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Button', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), Text('Pos: X:${10 + i*2}.5', style: theme.textTheme.bodySmall)])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('92%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12))),
              ]))),
          ],
        ),
      ),
    );
  }
}

// ============= EFFECTIVENESS SCORE SCREEN =============
class EffectivenessScoreScreen extends StatelessWidget {
  const EffectivenessScoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Effectiveness Score'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(elevation: 2, child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.success, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Text('Overall Effectiveness', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Text('87/100', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Text('Good', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ]),
            )),
            const SizedBox(height: 20),
            Text('Tooth-wise Scores', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final score in [92, 85, 78, 88])
              Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('T', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tooth', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)), Text('$score/100', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: score / 100, minHeight: 6, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation(score > 80 ? AppColors.success : AppColors.warning))),
                ])),
              ])),
          ],
        ),
      ),
    );
  }
}

// ============= PREDICTABILITY SCREEN =============
class PredictabilityScreen extends StatelessWidget {
  const PredictabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Predictability Analysis'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Column(children: [Text('82%', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)), Text('Predictability', style: theme.textTheme.bodySmall)]),
                Column(children: [Text('18%', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)), Text('Tracking Loss Risk', style: theme.textTheme.bodySmall)]),
              ]),
            ]))),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.error_outline, color: AppColors.error), const SizedBox(width: 8), Text('High-Risk Teeth Detected', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error))]),
              const SizedBox(height: 12),
              Text('Tooth #3', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('• Crown dilacerations\n• Severe angulation', style: theme.textTheme.bodySmall),
            ])),
          ],
        ),
      ),
    );
  }
}

// ============= RISK ANALYSIS SCREEN =============
class RiskAnalysisScreen extends StatelessWidget {
  const RiskAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final risks = [
      {'name': 'Root Resorption', 'percent': 35, 'color': AppColors.error},
      {'name': 'Bone Loss', 'percent': 15, 'color': AppColors.success},
      {'name': 'Attachment Failure', 'percent': 8, 'color': AppColors.success},
      {'name': 'Treatment Failure', 'percent': 22, 'color': AppColors.warning},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Analysis'), elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: risks.length, itemBuilder: (context, index) {
        final risk = risks[index];
        return Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(Icons.warning, color: risk['color'] as Color, size: 32),
          Text(risk['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('${risk['percent']}%', style: TextStyle(fontSize: 20, color: risk['color'] as Color, fontWeight: FontWeight.bold)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (risk['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('High Risk', style: TextStyle(color: risk['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold))),
        ])));
      })),
    );
  }
}

// ============= RECOMMENDATIONS SCREEN =============
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treatment Recommendations', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (int i = 1; i <= 3; i++)
              Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Tooth #$i', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: i == 1 ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(i == 1 ? 'High' : 'Medium', style: TextStyle(color: i == 1 ? AppColors.error : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Current', style: theme.textTheme.bodySmall), Text('Button', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))])), const Icon(Icons.arrow_forward, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Recommended', style: theme.textTheme.bodySmall), Text('Hook', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success))]))]),
                const SizedBox(height: 12),
                Text('Hook provides better rotational control', style: theme.textTheme.bodySmall),
              ]))),
          ],
        ),
      ),
    );
  }
}

// ============= VALIDATION SCREEN =============
class ValidationScreen extends StatelessWidget {
  const ValidationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Validation Report'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(elevation: 2, child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.success, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('Overall Accuracy', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Text('95%', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Text('Success', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ]),
            )),
            const SizedBox(height: 20),
            Text('Movement Comparison', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (int i = 1; i <= 3; i++)
              Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tooth #$i', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), Text('${93 + i}%', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Planned', style: theme.textTheme.bodySmall), Text('${2.5 + i * 0.5} mm', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))]),
                  const Icon(Icons.arrow_forward, color: AppColors.primary),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Achieved', style: theme.textTheme.bodySmall), Text('${2.4 + i * 0.5} mm', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))]),
                ]),
              ]))),
          ],
        ),
      ),
    );
  }
}
