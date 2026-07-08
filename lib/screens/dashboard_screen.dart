import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/mock_providers.dart';
import '../providers/patient_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'researcher_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    context.read<MockCaseProvider>().fetchUserCases();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [
            // ── Hero header ─────────────────────────────────────────────
            _HeroAppBar(isDark: isDark),

            // ── Body content ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats grid
                  _SectionHeader(title: 'Overview'),
                  const SizedBox(height: 12),
                  _StatsGrid(isDark: isDark),

                  const SizedBox(height: 28),

                  // Quick actions
                  _SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  _QuickActionsGrid(isDark: isDark),

                  const SizedBox(height: 28),

                  // Assigned patients (doctor only)
                  Consumer<AuthProvider>(builder: (_, auth, __) {
                    if (auth.currentUser?.role != UserRole.doctor) return const SizedBox.shrink();
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _SectionHeader(
                        title: 'Assigned Patients',
                        action: TextButton(
                          onPressed: () {},
                          child: const Text(''),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AssignedPatientsList(isDark: isDark),
                      const SizedBox(height: 28),
                    ]);
                  }),

                  // Recent cases
                  _SectionHeader(
                    title: 'Recent Cases',
                    action: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/cases'),
                      child: const Text('View All'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentCasesList(isDark: isDark),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/new-case'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Case',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

// ── Hero AppBar with gradient background
class _HeroAppBar extends StatelessWidget {
  final bool isDark;
  const _HeroAppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primaryDark,
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white70,
          ),
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(gradient: AppGradients.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      final user = auth.currentUser;
                      return Row(
                        children: [
                          // Avatar
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppGradients.tealGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white30, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (user?.name.isNotEmpty ?? false)
                                    ? user!.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good ${_greeting()}, 👋',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.65),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'Doctor',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Role chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.secondaryLight
                                      .withOpacity(0.5)),
                            ),
                            child: Text(
                              (user?.role.name ?? 'Doctor')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryPale,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ── Section header with optional action
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ── Statistics grid
class _StatsGrid extends StatelessWidget {
  final bool isDark;
  const _StatsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockCaseProvider>(
      builder: (_, caseProvider, __) {
        final cases = caseProvider.cases;
        final analyzed =
            cases.where((c) => c.latestAnalysisId != null).length;
        final active =
            cases.where((c) => c.status == CaseStatus.active).length;
        final completed =
            cases.where((c) => c.status == CaseStatus.completed).length;

        final stats = [
          _StatData(
            'Total Cases',
            cases.length.toString(),
            Icons.folder_open_rounded,
            AppGradients.primaryGradient,
            AppColors.primary,
          ),
          _StatData(
            'Analyzed',
            analyzed.toString(),
            Icons.analytics_rounded,
            AppGradients.tealGradient,
            AppColors.secondary,
          ),
          _StatData(
            'Active',
            active.toString(),
            Icons.task_alt_rounded,
            AppGradients.successGradient,
            AppColors.success,
          ),
          _StatData(
            'Completed',
            completed.toString(),
            Icons.check_circle_outline_rounded,
            AppGradients.purpleGradient,
            AppColors.accent,
          ),
        ];

        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 140,
              child: _AnimatedStatCard(data: stats[i], index: i, isDark: isDark),
            ),
          ),
        );
      },
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final Color accent;
  const _StatData(this.title, this.value, this.icon, this.gradient, this.accent);
}

class _AnimatedStatCard extends StatefulWidget {
  final _StatData data;
  final int index;
  final bool isDark;
  const _AnimatedStatCard(
      {required this.data, required this.index, required this.isDark});

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(Duration(milliseconds: 100 + widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDecorations.cardShadow,
          border: Border.all(
            color: widget.isDark
                ? AppColors.darkBorder
                : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: widget.data.gradient,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: widget.data.accent.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.data.icon, color: Colors.white, size: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: widget.data.accent,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.data.title,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick actions grid
class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;
  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('New Case', Icons.add_circle_outline_rounded,
          AppGradients.primaryGradient, '/new-case'),
      _ActionData('My Cases', Icons.folder_open_rounded,
          AppGradients.tealGradient, '/cases'),
      _ActionData('Upload STL', Icons.upload_file_rounded,
          AppGradients.successGradient, '/stl-upload'),
      _ActionData('Reports', Icons.description_rounded,
          AppGradients.purpleGradient, '/reports'),
      _ActionData('Analysis', Icons.analytics_rounded,
          AppGradients.warningGradient, '/attachment-detection'),
      _ActionData('Validation', Icons.fact_check_rounded,
          AppGradients.errorGradient, '/validation'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) => _ActionTile(
          action: actions[i], isDark: isDark),
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final String route;
  const _ActionData(this.label, this.icon, this.gradient, this.route);
}

class _ActionTile extends StatelessWidget {
  final _ActionData action;
  final bool isDark;
  const _ActionTile({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDecorations.cardShadow,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: action.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent cases list
class _RecentCasesList extends StatelessWidget {
  final bool isDark;
  const _RecentCasesList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockCaseProvider>(
      builder: (_, caseProvider, __) {
        if (caseProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (caseProvider.cases.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.border.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inbox_rounded,
                      size: 28, color: AppColors.primaryLight),
                ),
                const SizedBox(height: 16),
                Text('No cases yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Tap "+ New Case" to get started',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return Column(
          children: caseProvider.cases.take(5).map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CaseCard(caseItem: c, isDark: isDark),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CaseCard extends StatelessWidget {
  final CaseModel caseItem;
  final bool isDark;
  const _CaseCard({required this.caseItem, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(caseItem.status);
    final statusLabel = caseItem.status.toString().split('.').last;

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/case-detail', arguments: caseItem.caseId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.border.withOpacity(0.5)),
          boxShadow: AppDecorations.cardShadow,
        ),
        child: Row(
          children: [
            // Status indicator strip
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // Case info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caseItem.caseTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Patient: ${caseItem.patientName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Stats + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.insert_drive_file_outlined,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '${caseItem.stlFileIds.length} STL',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.science_outlined,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '${caseItem.totalAnalyses}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Color _statusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.active:
        return AppColors.success;
      case CaseStatus.completed:
        return AppColors.info;
      case CaseStatus.inReview:
        return AppColors.warning;
      case CaseStatus.archived:
        return AppColors.textTertiary;
    }
  }
}

// ── Assigned patients list for doctor dashboard
class _AssignedPatientsList extends StatelessWidget {
  final bool isDark;
  const _AssignedPatientsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, AuthProvider>(
      builder: (_, pp, auth, __) {
        final uid = auth.currentUser?.uid ?? '';
        final patients = pp.patientsForDoctor(uid);

        if (patients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5)),
            ),
            child: Column(children: [
              Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.people_outline_rounded, size: 24, color: AppColors.accent)),
              const SizedBox(height: 12),
              const Text('No patients assigned yet', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Researchers will assign patients to you',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textTertiary)),
            ]),
          );
        }

        return Column(
          children: patients.take(3).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AssignedPatientCard(patient: p, isDark: isDark),
          )).toList(),
        );
      },
    );
  }
}

class _AssignedPatientCard extends StatelessWidget {
  final PatientRecord patient;
  final bool isDark;
  const _AssignedPatientCard({required this.patient, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(patient.status);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: patient)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5)),
          boxShadow: AppDecorations.cardShadow,
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(gradient: AppGradients.purpleGradient, shape: BoxShape.circle),
            child: Center(child: Text(patient.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(patient.chiefComplaint,
                style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_statusLabel(patient.status),
                  style: TextStyle(color: statusColor, fontSize: 9,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
            const SizedBox(height: 4),
            Text('${patient.age}y · ${patient.gender}',
                style: Theme.of(context).textTheme.labelSmall),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ]),
      ),
    );
  }

  Color _statusColor(PatientStatus s) {
    switch (s) {
      case PatientStatus.pending: return AppColors.warning;
      case PatientStatus.assigned: return AppColors.success;
      case PatientStatus.inProgress: return AppColors.info;
      case PatientStatus.completed: return AppColors.textSecondary;
    }
  }

  String _statusLabel(PatientStatus s) {
    switch (s) {
      case PatientStatus.pending: return 'Pending';
      case PatientStatus.assigned: return 'Assigned';
      case PatientStatus.inProgress: return 'In Progress';
      case PatientStatus.completed: return 'Completed';
    }
  }
}
