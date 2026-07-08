import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient_record.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';

class ResearcherScreen extends StatefulWidget {
  const ResearcherScreen({Key? key}) : super(key: key);

  @override
  State<ResearcherScreen> createState() => _ResearcherScreenState();
}

class _ResearcherScreenState extends State<ResearcherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  PatientStatus? _filter; // null = All

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..forward();
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _openNewPatientForm() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const PatientEntryScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final researcherName = auth.currentUser?.name ?? 'Researcher';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [
            // ── Gradient header
            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              backgroundColor: AppColors.accent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppGradients.purpleGradient),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              researcherName.isNotEmpty ? researcherName[0] : 'R',
                              style: const TextStyle(color: Colors.white,
                                  fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello, ${researcherName.split(' ').first} 👋',
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins')),
                            const Text('Patient Management',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                                    color: Colors.white, fontFamily: 'Poppins')),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Text('RESEARCHER',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins', letterSpacing: 0.8)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      // Stats row
                      Consumer2<PatientProvider, AuthProvider>(
                        builder: (_, pp, auth, __) {
                          final uid = auth.currentUser?.uid ?? '';
                          final all = pp.patientsForResearcher(uid);
                          final pending = all.where((p) => p.status == PatientStatus.pending).length;
                          final assigned = all.where((p) => p.status == PatientStatus.assigned).length;
                          final inProg = all.where((p) => p.status == PatientStatus.inProgress).length;
                          return Row(children: [
                            _HeaderStat(label: 'Total', value: '${all.length}', color: Colors.white),
                            _HeaderStat(label: 'Pending', value: '$pending', color: const Color(0xFFFBBF24)),
                            _HeaderStat(label: 'Assigned', value: '$assigned', color: const Color(0xFF34D399)),
                            _HeaderStat(label: 'Active', value: '$inProg', color: const Color(0xFF60A5FA)),
                          ]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter chips
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FilterChip(label: 'All', isSelected: _filter == null,
                        onTap: () => setState(() => _filter = null)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Pending', isSelected: _filter == PatientStatus.pending,
                        onTap: () => setState(() => _filter = PatientStatus.pending),
                        color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Assigned', isSelected: _filter == PatientStatus.assigned,
                        onTap: () => setState(() => _filter = PatientStatus.assigned),
                        color: AppColors.success),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'In Progress', isSelected: _filter == PatientStatus.inProgress,
                        onTap: () => setState(() => _filter = PatientStatus.inProgress),
                        color: AppColors.info),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Completed', isSelected: _filter == PatientStatus.completed,
                        onTap: () => setState(() => _filter = PatientStatus.completed),
                        color: AppColors.textSecondary),
                  ]),
                ),
              ),
            ),

            // ── Patient list
            Consumer2<PatientProvider, AuthProvider>(
              builder: (_, pp, auth, __) {
                final uid = auth.currentUser?.uid ?? '';
                var patients = pp.patientsForResearcher(uid);
                if (_filter != null) {
                  patients = patients.where((p) => p.status == _filter).toList();
                }

                if (patients.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 72, height: 72,
                            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.person_add_rounded, size: 32, color: AppColors.accent)),
                        const SizedBox(height: 16),
                        const Text('No patients yet', style: TextStyle(fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Text('Tap + to add a new patient',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textTertiary)),
                      ]),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ResearcherPatientCard(
                          patient: patients[i],
                          onViewDetails: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PatientDetailScreen(patient: patients[i]),
                          )),
                        ),
                      ),
                      childCount: patients.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPatientForm,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Patient',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

// ── Patient card for researcher list
class _ResearcherPatientCard extends StatelessWidget {
  final PatientRecord patient;
  final VoidCallback onViewDetails;
  const _ResearcherPatientCard({required this.patient, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(patient.status);
    final statusLabel = _statusLabel(patient.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.purpleGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(patient.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name,
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                          fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${patient.age} yrs · ${patient.gender} · ${patient.contactNumber}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 10,
                        fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
              ),
            ]),
          ),

          // Complaint
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(child: Text(patient.chiefComplaint,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
          const SizedBox(height: 10),

          // Doctor assignment + files
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: patient.assignedDoctorId.isEmpty
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(patient.assignedDoctorId.isEmpty ? Icons.person_off_outlined : Icons.person_rounded,
                      size: 12, color: patient.assignedDoctorId.isEmpty ? AppColors.warning : AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    patient.assignedDoctorId.isEmpty ? 'Unassigned' : patient.assignedDoctorName,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600,
                        color: patient.assignedDoctorId.isEmpty ? AppColors.warning : AppColors.success),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              if (patient.attachedFiles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.attach_file_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${patient.attachedFiles.length} files',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                            fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onViewDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppGradients.purpleGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins',
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ],
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

// ── Header stat chip
class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HeaderStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18)),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Poppins', fontSize: 9)),
  ]));
}

// ── Filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color : AppColors.border),
        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)] : null,
      ),
      child: Text(label,
          style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary,
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12)),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// PATIENT ENTRY FORM SCREEN
// ══════════════════════════════════════════════════════════════

class PatientEntryScreen extends StatefulWidget {
  const PatientEntryScreen({Key? key}) : super(key: key);

  @override
  State<PatientEntryScreen> createState() => _PatientEntryScreenState();
}

class _PatientEntryScreenState extends State<PatientEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _complaintCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _gender = 'Male';
  Map<String, String>? _selectedDoctor;
  bool _isSaving = false;
  bool _isPickingFiles = false;
  final List<PlatformFile> _pickedFiles = [];

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _ageCtrl, _contactCtrl, _emailCtrl,
      _complaintCtrl, _historyCtrl, _medsCtrl, _allergiesCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please assign a doctor', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final now = DateTime.now();

    final record = PatientRecord(
      patientId: 'pat_${now.millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      gender: _gender,
      contactNumber: _contactCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      chiefComplaint: _complaintCtrl.text.trim(),
      medicalHistory: _historyCtrl.text.trim(),
      currentMedications: _medsCtrl.text.trim().isEmpty ? null : _medsCtrl.text.trim(),
      allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      assignedDoctorId: _selectedDoctor!['id']!,
      assignedDoctorName: _selectedDoctor!['name']!,
      researcherId: auth.currentUser?.uid ?? 'demo_researcher_001',
      researcherName: auth.currentUser?.name ?? 'Dr. Arjun Nair',
      status: PatientStatus.assigned,
      attachedFiles: _pickedFiles.map((f) => f.name).toList(),
      createdAt: now,
      updatedAt: now,
    );

    final patientProvider = context.read<PatientProvider>();
    await patientProvider.addPatient(record);
    // Store file bytes so doctors can view them
    final fileMap = <String, Uint8List>{};
    for (final f in _pickedFiles) {
      if (f.bytes != null) fileMap[f.name] = f.bytes!;
    }
    if (fileMap.isNotEmpty) patientProvider.storeFiles(record.patientId, fileMap);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Text('Patient assigned to ${_selectedDoctor!['name']}',
              style: const TextStyle(fontFamily: 'Poppins')),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Patient Entry',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personal Info
              _FormSection(
                title: 'Personal Information',
                icon: Icons.person_rounded,
                iconColor: AppColors.accent,
                children: [
                  _FormRow(children: [
                    Expanded(child: _Field(
                      ctrl: _nameCtrl, label: 'Full Name',
                      hint: 'Patient full name',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    )),
                    const SizedBox(width: 12),
                    SizedBox(width: 80, child: _Field(
                      ctrl: _ageCtrl, label: 'Age',
                      hint: '25', keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    )),
                  ]),
                  const SizedBox(height: 14),
                  // Gender dropdown
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Gender', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          items: _genders.map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _Field(ctrl: _contactCtrl, label: 'Contact Number', hint: '+91 98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 14),
                  _Field(ctrl: _emailCtrl, label: 'Email', hint: 'patient@email.com',
                      keyboardType: TextInputType.emailAddress),
                ],
              ),
              const SizedBox(height: 16),

              // ── Clinical Info
              _FormSection(
                title: 'Clinical Information',
                icon: Icons.medical_services_rounded,
                iconColor: AppColors.primary,
                children: [
                  _Field(ctrl: _complaintCtrl, label: 'Chief Complaint',
                      hint: 'Describe the main concern...',
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 14),
                  _Field(ctrl: _historyCtrl, label: 'Medical History',
                      hint: 'Previous conditions, surgeries, etc.',
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 14),
                  _Field(ctrl: _medsCtrl, label: 'Current Medications',
                      hint: 'List medications or "None"', maxLines: 2),
                  const SizedBox(height: 14),
                  _Field(ctrl: _allergiesCtrl, label: 'Known Allergies',
                      hint: 'Latex, penicillin, etc. or "None"'),
                ],
              ),
              const SizedBox(height: 16),

              // ── File Attachments (mock)
              _FormSection(
                title: 'Attach Files',
                icon: Icons.attach_file_rounded,
                iconColor: AppColors.info,
                children: [
                  if (_pickedFiles.isNotEmpty) ...[
                    ..._pickedFiles.map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                            color: AppColors.textSecondary))),
                        GestureDetector(
                          onTap: () => setState(() => _pickedFiles.remove(f)),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                        ),
                      ]),
                    )),
                    const SizedBox(height: 8),
                  ],
                  GestureDetector(
                    onTap: _isPickingFiles ? null : () async {
                      setState(() => _isPickingFiles = true);
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                          type: FileType.custom,
                          allowedExtensions: [
                            'stl', 'obj', 'ply',           // 3D models
                            'jpg', 'jpeg', 'png', 'bmp',   // images
                            'pdf',                          // documents
                            'zip', 'dcm',                  // archives / DICOM
                          ],
                        );
                        if (result != null) {
                          setState(() {
                            for (final f in result.files) {
                              if (f.name.isNotEmpty &&
                                  !_pickedFiles.any((p) => p.name == f.name)) {
                                _pickedFiles.add(f);
                              }
                            }
                          });
                        }
                      } finally {
                        if (mounted) setState(() => _isPickingFiles = false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isPickingFiles ? AppColors.info : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: _isPickingFiles
                          ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info)),
                              SizedBox(width: 10),
                              Text('Opening file picker...',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                                      color: AppColors.info)),
                            ])
                          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.cloud_upload_outlined, color: AppColors.info, size: 20),
                              SizedBox(width: 8),
                              Text('Add STL / X-Ray / Photo',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                                      color: AppColors.info, fontWeight: FontWeight.w500)),
                            ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Assign Doctor
              _FormSection(
                title: 'Assign Doctor',
                icon: Icons.local_hospital_rounded,
                iconColor: AppColors.success,
                children: [
                  ...context.read<PatientProvider>().availableDoctors.map((doc) {
                    final isSelected = _selectedDoctor?['id'] == doc['id'];
                    final initials = (doc['name'] ?? 'D')
                        .split(' ')
                        .where((w) => w.isNotEmpty)
                        .take(2)
                        .map((w) => w[0])
                        .join();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDoctor = doc),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.success.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.success : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppGradients.successGradient : null,
                              color: isSelected ? null : AppColors.gray100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(initials,
                                style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(doc['name']!,
                                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                                    fontSize: 14, color: isSelected ? AppColors.success : AppColors.textPrimary)),
                            if ((doc['specialization'] ?? '').isNotEmpty)
                              Text(doc['specialization']!,
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary)),
                          ])),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success),
                        ]),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // ── Notes
              _FormSection(
                title: 'Additional Notes',
                icon: Icons.notes_rounded,
                iconColor: AppColors.textSecondary,
                children: [
                  _Field(ctrl: _notesCtrl, label: 'Notes for Doctor',
                      hint: 'Any special considerations, urgency, or context...', maxLines: 4),
                ],
              ),
              const SizedBox(height: 24),

              // ── Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSaving ? 'Assigning...' : 'Assign to Doctor',
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Form section card
class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  const _FormSection({required this.title, required this.icon, required this.iconColor, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: iconColor)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
            fontSize: 14, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 14),
      const Divider(height: 1, color: AppColors.border),
      const SizedBox(height: 14),
      ...children,
    ]),
  );
}

class _FormRow extends StatelessWidget {
  final List<Widget> children;
  const _FormRow({required this.children});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

// ── Form field
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field({required this.ctrl, required this.label, required this.hint,
    this.maxLines = 1, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, maxLines: maxLines,
        keyboardType: keyboardType, validator: validator,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textTertiary),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accent, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error)),
          errorStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 10),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// PATIENT DETAIL SCREEN (shared by Doctor + Researcher)
// ══════════════════════════════════════════════════════════════

class PatientDetailScreen extends StatelessWidget {
  final PatientRecord patient;
  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    // Always pull the live record from the provider so status updates are instant
    final live = patientProvider.allPatients.firstWhere(
          (p) => p.patientId == patient.patientId,
          orElse: () => patient,
        );
    final statusColor = _statusColor(live.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.heroGradient),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          gradient: AppGradients.tealGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 2),
                        ),
                        child: Center(child: Text(patient.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800, fontSize: 22))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800, fontSize: 18)),
                          const SizedBox(height: 3),
                          Text('${patient.age} yrs · ${patient.gender} · ${patient.contactNumber}',
                              style: TextStyle(color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Poppins', fontSize: 12)),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(_statusLabel(live.status),
                            style: TextStyle(color: statusColor, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Assignment info
                _DetailCard(
                  title: 'Assignment', icon: Icons.assignment_ind_rounded, iconColor: AppColors.success,
                  children: [
                    _DetailRow(label: 'Assigned Doctor', value: patient.assignedDoctorName, valueColor: AppColors.success),
                    _DetailRow(label: 'Referred by', value: patient.researcherName),
                    _DetailRow(label: 'Date Added', value: _formatDate(patient.createdAt)),
                    _DetailRow(label: 'Last Updated', value: _formatDate(patient.updatedAt)),
                  ],
                ),
                const SizedBox(height: 12),

                // Clinical info
                _DetailCard(
                  title: 'Clinical Information', icon: Icons.medical_services_rounded, iconColor: AppColors.primary,
                  children: [
                    _DetailBlock(label: 'Chief Complaint', value: patient.chiefComplaint),
                    _DetailBlock(label: 'Medical History', value: patient.medicalHistory),
                    if (patient.currentMedications != null)
                      _DetailRow(label: 'Medications', value: patient.currentMedications!),
                    if (patient.allergies != null)
                      _DetailRow(label: 'Allergies', value: patient.allergies!, valueColor: AppColors.error),
                  ],
                ),
                const SizedBox(height: 12),

                // Files
                if (live.attachedFiles.isNotEmpty) ...[
                  _DetailCard(
                    title: 'Attached Files (${live.attachedFiles.length})',
                    icon: Icons.folder_open_rounded, iconColor: AppColors.info,
                    children: live.attachedFiles.map((f) {
                      final bytes = patientProvider.getFile(live.patientId, f);
                      final hasFile = bytes != null;
                      return GestureDetector(
                        onTap: hasFile ? () => _openFile(context, f, bytes) : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: hasFile
                                ? AppColors.info.withOpacity(0.06)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasFile
                                  ? AppColors.info.withOpacity(0.35)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(children: [
                            Icon(_fileIcon(f), size: 18,
                                color: hasFile ? AppColors.info : AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(child: Text(f,
                                style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 12,
                                  color: hasFile ? AppColors.info : AppColors.textSecondary,
                                  fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                                ))),
                            Icon(
                              hasFile ? Icons.open_in_new_rounded : Icons.hourglass_empty_rounded,
                              size: 16,
                              color: hasFile ? AppColors.info : AppColors.textTertiary,
                            ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Notes
                if (patient.notes != null) ...[
                  _DetailCard(
                    title: 'Notes', icon: Icons.sticky_note_2_rounded, iconColor: AppColors.accent,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                        ),
                        child: Text(patient.notes!,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                                color: AppColors.textSecondary, height: 1.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Status update (for doctor)
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    if (auth.currentUser?.role != UserRole.doctor) return const SizedBox.shrink();
                    return _StatusUpdateCard(patient: live);
                  },
                ),

                const SizedBox(height: 12),

                // Clinical analysis + final report (for doctor)
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    if (auth.currentUser?.role != UserRole.doctor) return const SizedBox.shrink();
                    return _DoctorAnalysisReport(patient: live);
                  },
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
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

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  IconData _fileIcon(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.stl') || lower.endsWith('.obj') || lower.endsWith('.ply')) {
      return Icons.view_in_ar_rounded;
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.bmp')) {
      return Icons.image_rounded;
    }
    if (lower.endsWith('.pdf')) { return Icons.picture_as_pdf_rounded; }
    if (lower.endsWith('.zip')) { return Icons.folder_zip_rounded; }
    return Icons.insert_drive_file_rounded;
  }

  void _openFile(BuildContext context, String name, Uint8List bytes) {
    final lower = name.toLowerCase();
    final isImage = lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.bmp');

    if (isImage) {
      // Show image preview dialog
      showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(name,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      );
    } else {
      // Trigger browser download for non-image files (web only)
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', name)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    }
  }
}

// ── Status update card (doctor only)
class _StatusUpdateCard extends StatelessWidget {
  final PatientRecord patient;
  const _StatusUpdateCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.update_rounded, size: 16, color: AppColors.info)),
          const SizedBox(width: 10),
          const Text('Update Status', style: TextStyle(fontFamily: 'Poppins',
              fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _StatusBtn(
            label: 'In Progress',
            color: AppColors.info,
            isActive: patient.status == PatientStatus.inProgress,
            onTap: () => context.read<PatientProvider>().updateStatus(patient.patientId, PatientStatus.inProgress),
          )),
          const SizedBox(width: 10),
          Expanded(child: _StatusBtn(
            label: 'Completed',
            color: AppColors.success,
            isActive: patient.status == PatientStatus.completed,
            onTap: () => context.read<PatientProvider>().updateStatus(patient.patientId, PatientStatus.completed),
          )),
        ]),
      ]),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _StatusBtn({required this.label, required this.color, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isActive ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(child: Text(label,
          style: TextStyle(color: isActive ? Colors.white : color,
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13))),
    ),
  );
}

// ── Detail helpers
class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.icon, required this.iconColor, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: iconColor)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
            fontSize: 14, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 12),
      const Divider(height: 1, color: AppColors.border),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textTertiary)),
      Flexible(child: Text(value,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary),
          textAlign: TextAlign.end, maxLines: 2)),
    ]),
  );
}

class _DetailBlock extends StatelessWidget {
  final String label, value;
  const _DetailBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
          fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textSecondary, height: 1.5)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// DOCTOR ANALYSIS REPORT (Doctor-only section in PatientDetail)
// ══════════════════════════════════════════════════════════════

class _DoctorAnalysisReport extends StatefulWidget {
  final PatientRecord patient;
  const _DoctorAnalysisReport({required this.patient});

  @override
  State<_DoctorAnalysisReport> createState() => _DoctorAnalysisReportState();
}

class _DoctorAnalysisReportState extends State<_DoctorAnalysisReport> {
  final _diagnosisCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _recommendCtrl = TextEditingController();
  bool _reportGenerated = false;

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _findingsCtrl.dispose();
    _treatmentCtrl.dispose();
    _recommendCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    if (_diagnosisCtrl.text.trim().isEmpty || _treatmentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please fill in Diagnosis and Treatment Plan',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _reportGenerated = true);
  }

  bool _isGeneratingPdf = false;

  Future<void> _downloadPDF() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final doctorName = context.read<AuthProvider>().currentUser?.name ?? 'Doctor';
      final now = DateTime.now();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
      final bytes = await _buildClinicalReportPdf(
        patient: widget.patient,
        doctorName: doctorName,
        dateStr: dateStr,
        diagnosis: _diagnosisCtrl.text,
        findings: _findingsCtrl.text,
        treatment: _treatmentCtrl.text,
        recommendations: _recommendCtrl.text,
      );
      _triggerPdfDownload(bytes, widget.patient.name);
      // Store the report PDF in the patient's record for future viewing
      final reportName = 'Clinical_Report_${widget.patient.name.replaceAll(' ', '_')}.pdf';
      context.read<PatientProvider>().addFileToPatient(
          widget.patient.patientId, reportName, bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('PDF downloaded & saved to patient record',
                style: TextStyle(fontFamily: 'Poppins')),
          ]),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _showSendDialog() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final doctorName = context.read<AuthProvider>().currentUser?.name ?? 'Doctor';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SendReportSheet(
        patient: widget.patient,
        doctorName: doctorName,
        dateStr: dateStr,
        diagnosis: _diagnosisCtrl.text,
        findings: _findingsCtrl.text,
        treatment: _treatmentCtrl.text,
        recommendations: _recommendCtrl.text,
      ),
    ).then((result) {
      if (!mounted) return;
      if (result == 'email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(child: Text(
              'PDF downloaded — attach it to your email to ${widget.patient.email}',
              style: const TextStyle(fontFamily: 'Poppins'),
            )),
          ]),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      } else if (result == 'whatsapp') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            SizedBox(width: 10),
            Flexible(child: Text(
              'PDF downloaded — share it in WhatsApp',
              style: TextStyle(fontFamily: 'Poppins'),
            )),
          ]),
          backgroundColor: const Color(0xFF25D366),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = context.watch<AuthProvider>().currentUser?.name ?? 'Doctor';
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section header
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.description_rounded, size: 16, color: Colors.white)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Clinical Analysis & Final Report',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 14, color: AppColors.textPrimary))),
          if (_reportGenerated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('READY',
                  style: TextStyle(color: AppColors.success, fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.8)),
            ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 14),

        if (!_reportGenerated) ...[
          // ── Input form
          _ReportField(ctrl: _diagnosisCtrl, label: 'Diagnosis *',
              hint: 'e.g. Class II malocclusion with moderate crowding in upper arch',
              maxLines: 3),
          const SizedBox(height: 12),
          _ReportField(ctrl: _findingsCtrl, label: 'STL Analysis Findings',
              hint: 'Attachment points, measurements, bone density observations...',
              maxLines: 3),
          const SizedBox(height: 12),
          _ReportField(ctrl: _treatmentCtrl, label: 'Treatment Plan *',
              hint: 'Aligner therapy with 14 stages, attachment on #13, #23...',
              maxLines: 4),
          const SizedBox(height: 12),
          _ReportField(ctrl: _recommendCtrl, label: 'Recommendations & Follow-up',
              hint: 'Monthly check-ups, retainer after treatment, dietary restrictions...',
              maxLines: 3),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Generate Final Report',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
          ),
        ] else ...[
          // ── Report preview
          Container(
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Doc header
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CLINICAL FINAL REPORT',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800,
                          fontSize: 12, color: AppColors.primary, letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text('AI Orthodontic Platform',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
                          color: AppColors.textTertiary)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withOpacity(0.3))),
                  child: const Text('FINAL',
                      style: TextStyle(color: AppColors.success, fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.8)),
                ),
              ]),
              const Divider(height: 20, color: AppColors.border),

              // Patient + Doctor info grid
              Row(children: [
                Expanded(child: _ReportInfoCol(
                    label: 'PATIENT', value: widget.patient.name)),
                Expanded(child: _ReportInfoCol(
                    label: 'PHYSICIAN', value: doctorName)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _ReportInfoCol(
                    label: 'AGE / GENDER',
                    value: '${widget.patient.age} yrs · ${widget.patient.gender}')),
                Expanded(child: _ReportInfoCol(
                    label: 'REPORT DATE',
                    value: '${now.day} ${months[now.month - 1]} ${now.year}')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _ReportInfoCol(
                    label: 'CONTACT', value: widget.patient.contactNumber)),
                Expanded(child: _ReportInfoCol(
                    label: 'EMAIL', value: widget.patient.email)),
              ]),
              const Divider(height: 20, color: AppColors.border),

              // Report content sections
              _ReportSec(title: 'DIAGNOSIS', content: _diagnosisCtrl.text, color: AppColors.primary),
              if (_findingsCtrl.text.trim().isNotEmpty)
                _ReportSec(title: 'STL ANALYSIS FINDINGS', content: _findingsCtrl.text, color: AppColors.info),
              _ReportSec(title: 'TREATMENT PLAN', content: _treatmentCtrl.text, color: AppColors.secondary),
              if (_recommendCtrl.text.trim().isNotEmpty)
                _ReportSec(title: 'RECOMMENDATIONS', content: _recommendCtrl.text, color: AppColors.accent),

              const Divider(height: 20, color: AppColors.border),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Prepared by: $doctorName',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                        fontStyle: FontStyle.italic, color: AppColors.textTertiary)),
                Text('Ref: ${widget.patient.patientId.toUpperCase()}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 9,
                        color: AppColors.textTertiary)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Action buttons
          Row(children: [
            // Edit
            Expanded(child: OutlinedButton.icon(
              onPressed: () => setState(() => _reportGenerated = false),
              icon: const Icon(Icons.edit_rounded, size: 15),
              label: const Text('Edit',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            const SizedBox(width: 8),
            // Print PDF
            Expanded(child: ElevatedButton.icon(
              onPressed: _isGeneratingPdf ? null : _downloadPDF,
              icon: _isGeneratingPdf
                  ? const SizedBox(width: 15, height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf_rounded, size: 15),
              label: Text(_isGeneratingPdf ? 'Generating…' : 'Print PDF',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            )),
            const SizedBox(width: 8),
            // Send to patient
            Expanded(child: ElevatedButton.icon(
              onPressed: _showSendDialog,
              icon: const Icon(Icons.send_rounded, size: 15),
              label: const Text('Send',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ── Report form field
class _ReportField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  const _ReportField({required this.ctrl, required this.label,
      required this.hint, this.maxLines = 2});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
          fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl, maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textTertiary),
          filled: true, fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    ],
  );
}

// ── Report preview helpers
class _ReportInfoCol extends StatelessWidget {
  final String label, value;
  const _ReportInfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 8,
          fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis),
    ],
  );
}

class _ReportSec extends StatelessWidget {
  final String title, content;
  final Color color;
  const _ReportSec({required this.title, required this.content, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 12, color: color,
            margin: const EdgeInsets.only(right: 6)),
        Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 9,
            fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
      ]),
      const SizedBox(height: 5),
      Text(content, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
          color: AppColors.textPrimary, height: 1.6)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// SEND REPORT BOTTOM SHEET
// ══════════════════════════════════════════════════════════════

class _SendReportSheet extends StatefulWidget {
  final PatientRecord patient;
  final String doctorName;
  final String dateStr;
  final String diagnosis;
  final String findings;
  final String treatment;
  final String recommendations;
  const _SendReportSheet({
    required this.patient,
    required this.doctorName,
    required this.dateStr,
    required this.diagnosis,
    required this.findings,
    required this.treatment,
    required this.recommendations,
  });

  @override
  State<_SendReportSheet> createState() => _SendReportSheetState();
}

class _SendReportSheetState extends State<_SendReportSheet> {
  final _phoneCtrl = TextEditingController();
  bool _showWhatsAppInput = false;
  String? _phoneError;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.patient.contactNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    setState(() => _isSending = true);
    try {
      final bytes = await _buildClinicalReportPdf(
        patient: widget.patient,
        doctorName: widget.doctorName,
        dateStr: widget.dateStr,
        diagnosis: widget.diagnosis,
        findings: widget.findings,
        treatment: widget.treatment,
        recommendations: widget.recommendations,
      );
      _triggerPdfDownload(bytes, widget.patient.name);
      // Store the report in patient record
      if (mounted) {
        final reportName =
            'Clinical_Report_${widget.patient.name.replaceAll(' ', '_')}.pdf';
        context.read<PatientProvider>().addFileToPatient(
            widget.patient.patientId, reportName, bytes);
      }
      // Open email client (user attaches the downloaded PDF)
      final subject = Uri.encodeComponent(
          'Clinical Report – ${widget.patient.name}');
      final body = Uri.encodeComponent(
          'Dear ${widget.patient.name},\n\nPlease find your clinical report attached as a PDF.\n\nReport prepared by: ${widget.doctorName}\nDate: ${widget.dateStr}\nRef: ${widget.patient.patientId.toUpperCase()}\n\nAI Orthodontic Platform');
      html.window.location.href =
          'mailto:${widget.patient.email}?subject=$subject&body=$body';
      if (mounted) Navigator.of(context).pop('email');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendWhatsApp() async {
    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phone.length < 7) {
      setState(() => _phoneError = 'Enter a valid mobile number');
      return;
    }
    setState(() => _isSending = true);
    try {
      final bytes = await _buildClinicalReportPdf(
        patient: widget.patient,
        doctorName: widget.doctorName,
        dateStr: widget.dateStr,
        diagnosis: widget.diagnosis,
        findings: widget.findings,
        treatment: widget.treatment,
        recommendations: widget.recommendations,
      );
      _triggerPdfDownload(bytes, widget.patient.name);
      // Open WhatsApp Web directly to this phone number
      html.window.open('https://wa.me/$phone', '_blank');
      if (mounted) {
        Navigator.of(context).pop('whatsapp');
        // Show step-by-step instruction dialog
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF25D366)),
                SizedBox(width: 10),
                Text('Attach PDF in WhatsApp',
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The PDF was downloaded to your device. To send it in WhatsApp:',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                          color: AppColors.textSecondary)),
                  SizedBox(height: 12),
                  _StepRow(n: '1', text: 'WhatsApp Web opened in a new tab'),
                  _StepRow(n: '2', text: 'In WhatsApp, click the 📎 attachment icon'),
                  _StepRow(n: '3', text: 'Choose "Document" and select the downloaded PDF'),
                  _StepRow(n: '4', text: 'Send it to the patient'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF25D366))),
                ),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 20),

          const Text('Send Report to Patient',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 17, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Choose how to deliver the clinical report',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: AppColors.textTertiary)),
          const SizedBox(height: 20),

          // ── Email option
          _SendOptionTile(
            icon: Icons.email_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.primary.withOpacity(0.08),
            title: 'Send via Email',
            subtitle: widget.patient.email.isNotEmpty
                ? widget.patient.email
                : 'No email on record',
            actionLabel: _isSending ? 'Generating…' : 'Send PDF',
            onTap: (_isSending || widget.patient.email.isEmpty) ? null : _sendEmail,
          ),
          const SizedBox(height: 12),

          // ── WhatsApp option
          if (!_showWhatsAppInput)
            _SendOptionTile(
              icon: Icons.chat_rounded,
              iconColor: const Color(0xFF25D366),
              bgColor: const Color(0xFF25D366).withOpacity(0.08),
              title: 'Send via WhatsApp',
              subtitle: 'Enter mobile number to send PDF',
              actionLabel: 'Enter Number',
              onTap: _isSending ? null : () => setState(() => _showWhatsAppInput = true),
            )
          else ...[
            // WhatsApp phone input expanded
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
                  SizedBox(width: 8),
                  Text('Send via WhatsApp',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                          fontSize: 14, color: Color(0xFF25D366))),
                ]),
                const SizedBox(height: 12),
                const Text('Mobile Number (with country code)',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                        fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() => _phoneError = null),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14,
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: '919876543210',
                    hintStyle: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.phone_rounded,
                        size: 18, color: Color(0xFF25D366)),
                    errorText: _phoneError,
                    errorStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 10),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF25D366), width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Include country code without + (e.g. 919876543210)',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: AppColors.textTertiary)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => setState(() {
                      _showWhatsAppInput = false;
                      _phoneError = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendWhatsApp,
                    icon: _isSending
                        ? const SizedBox(width: 15, height: 15,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf_rounded, size: 15),
                    label: Text(_isSending ? 'Generating…' : 'Send PDF',
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  )),
                ]),
              ]),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SendOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bgColor;
  final String title, subtitle, actionLabel;
  final VoidCallback? onTap;
  const _SendOptionTile({
    required this.icon, required this.iconColor, required this.bgColor,
    required this.title, required this.subtitle,
    required this.actionLabel, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: disabled ? AppColors.gray100 : bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled ? AppColors.border : iconColor.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: disabled ? AppColors.border : iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22,
                color: disabled ? AppColors.textTertiary : iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: disabled ? AppColors.textTertiary : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    color: disabled ? AppColors.textTertiary : AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: disabled ? AppColors.border : iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(actionLabel,
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: disabled ? AppColors.textTertiary : Colors.white)),
          ),
        ]),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String n, text;
  const _StepRow({required this.n, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 20, height: 20,
        margin: const EdgeInsets.only(right: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF25D366), shape: BoxShape.circle),
        child: Center(child: Text(n,
            style: const TextStyle(color: Colors.white,
                fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 10))),
      ),
      Expanded(child: Text(text,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
              color: AppColors.textSecondary))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// PDF GENERATION HELPERS (top-level, shared by download + send)
// ══════════════════════════════════════════════════════════════

Future<Uint8List> _buildClinicalReportPdf({
  required PatientRecord patient,
  required String doctorName,
  required String dateStr,
  required String diagnosis,
  required String findings,
  required String treatment,
  required String recommendations,
}) async {
  final doc = pw.Document(
    title: 'Clinical Report – ${patient.name}',
    author: doctorName,
    subject: 'Orthodontic Clinical Report',
    creator: 'AI Orthodontic Platform',
  );

  const headerBg = PdfColor(0.118, 0.251, 0.686);   // #1E40AF deep blue
  const accentA  = PdfColor(0.118, 0.251, 0.686);   // DIAGNOSIS – blue
  const accentB  = PdfColor(0.016, 0.522, 0.620);   // FINDINGS – teal
  const accentC  = PdfColor(0.063, 0.494, 0.306);   // TREATMENT – green
  const accentD  = PdfColor(0.431, 0.231, 0.859);   // RECOMMENDATIONS – purple
  const textDark = PdfColor(0.118, 0.161, 0.306);
  const textMid  = PdfColor(0.392, 0.455, 0.573);
  const bgCard   = PdfColor(0.973, 0.98, 0.992);
  const bdColor  = PdfColor(0.878, 0.906, 0.941);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 48),
    footer: (ctx) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('AI Orthodontic Platform — Confidential Medical Document',
              style: pw.TextStyle(fontSize: 7, color: textMid,
                  fontStyle: pw.FontStyle.italic)),
          pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 7, color: textMid)),
        ],
      ),
    ),
    build: (ctx) => [
      // ── Header
      pw.Container(
        decoration: pw.BoxDecoration(
          color: headerBg,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CLINICAL FINAL REPORT',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 17,
                      fontWeight: pw.FontWeight.bold, letterSpacing: 0.4)),
              pw.SizedBox(height: 4),
              pw.Text('AI Orthodontic Platform',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const pw.BoxDecoration(color: PdfColors.white),
                child: pw.Text('FINAL',
                    style: pw.TextStyle(color: headerBg, fontSize: 9,
                        fontWeight: pw.FontWeight.bold, letterSpacing: 1.2)),
              ),
              pw.SizedBox(height: 5),
              pw.Text(dateStr,
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Ref: ${patient.patientId.toUpperCase()}',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 8)),
            ]),
          ],
        ),
      ),
      pw.SizedBox(height: 18),

      // ── Patient info grid
      pw.Container(
        decoration: pw.BoxDecoration(
          color: bgCard,
          border: pw.Border.all(color: bdColor),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        padding: const pw.EdgeInsets.all(14),
        child: pw.Column(children: [
          pw.Row(children: [
            pw.Expanded(child: _pdfCell('PATIENT', patient.name, textDark, textMid)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _pdfCell('PHYSICIAN', doctorName, textDark, textMid)),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: _pdfCell('AGE / GENDER',
                '${patient.age} yrs · ${patient.gender}', textDark, textMid)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _pdfCell('REPORT DATE', dateStr, textDark, textMid)),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            pw.Expanded(child: _pdfCell('CONTACT', patient.contactNumber, textDark, textMid)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _pdfCell('EMAIL', patient.email, textDark, textMid)),
          ]),
        ]),
      ),
      pw.SizedBox(height: 16),
      pw.Divider(color: bdColor),
      pw.SizedBox(height: 14),

      // ── Report sections
      _pdfSection('DIAGNOSIS', diagnosis, accentA, bgCard, bdColor, textDark),
      if (findings.trim().isNotEmpty)
        _pdfSection('STL ANALYSIS FINDINGS', findings, accentB, bgCard, bdColor, textDark),
      _pdfSection('TREATMENT PLAN', treatment, accentC, bgCard, bdColor, textDark),
      if (recommendations.trim().isNotEmpty)
        _pdfSection('RECOMMENDATIONS & FOLLOW-UP', recommendations, accentD, bgCard, bdColor, textDark),

      pw.SizedBox(height: 20),
      pw.Divider(color: bdColor),
      pw.SizedBox(height: 12),

      // ── Signature
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(doctorName,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold,
                    color: textDark)),
            pw.SizedBox(height: 2),
            pw.Text('Treating Physician · AI Orthodontic Platform',
                style: pw.TextStyle(fontSize: 9, color: textMid)),
          ]),
          pw.Text('Generated: $dateStr',
              style: pw.TextStyle(fontSize: 9, color: textMid,
                  fontStyle: pw.FontStyle.italic)),
        ],
      ),
    ],
  ));

  return doc.save();
}

pw.Widget _pdfCell(String label, String value,
    PdfColor textDark, PdfColor textMid) =>
  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(label,
        style: pw.TextStyle(fontSize: 7, color: textMid, letterSpacing: 0.8,
            fontWeight: pw.FontWeight.bold)),
    pw.SizedBox(height: 2),
    pw.Text(value,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
            color: textDark)),
  ]);

pw.Widget _pdfSection(String title, String content, PdfColor accent,
    PdfColor bg, PdfColor border, PdfColor textDark) =>
  pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.Container(width: 3, height: 13, color: accent),
        pw.SizedBox(width: 8),
        pw.Text(title,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold,
                color: accent, letterSpacing: 0.8)),
      ]),
      pw.SizedBox(height: 6),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bg,
          border: pw.Border.all(color: border),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(content,
            style: pw.TextStyle(fontSize: 11, color: textDark, lineSpacing: 3)),
      ),
    ]),
  );

void _triggerPdfDownload(Uint8List bytes, String patientName) {
  final safe = patientName.trim().replaceAll(RegExp(r'[^\w ]'), '').replaceAll(' ', '_');
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'Clinical_Report_$safe.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}
