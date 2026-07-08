import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient_record.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';

class STLUploadScreen extends StatefulWidget {
  const STLUploadScreen({Key? key}) : super(key: key);

  @override
  State<STLUploadScreen> createState() => _STLUploadScreenState();
}

class _STLUploadScreenState extends State<STLUploadScreen> {
  PatientRecord? _selectedPatient;
  final List<PlatformFile> _pickedFiles = [];
  bool _isPicking = false;
  bool _isSaving = false;

  List<PatientRecord> _myPatients(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final doctorId = auth.currentUser?.uid ?? '';
    return context
        .read<PatientProvider>()
        .allPatients
        .where((p) =>
            p.assignedDoctorId == doctorId ||
            p.assignedDoctorId == 'demo_doctor_001')
        .toList();
  }

  Future<void> _pickFiles() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'stl', 'obj', 'ply',         // 3D models
          'jpg', 'jpeg', 'png', 'bmp', // images / X-rays
          'pdf', 'zip', 'dcm',         // documents / DICOM
        ],
      );
      if (result != null) {
        setState(() {
          for (final f in result.files) {
            if (f.name.isNotEmpty && !_pickedFiles.any((p) => p.name == f.name)) {
              _pickedFiles.add(f);
            }
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _saveToPatient() async {
    if (_selectedPatient == null) {
      _showSnack('Please select a patient first', AppColors.error);
      return;
    }
    if (_pickedFiles.isEmpty) {
      _showSnack('Please pick at least one file', AppColors.error);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final provider = context.read<PatientProvider>();
      for (final f in _pickedFiles) {
        if (f.bytes != null) {
          provider.addFileToPatient(_selectedPatient!.patientId, f.name, f.bytes!);
        }
      }
      if (mounted) {
        _showSnack(
          '${_pickedFiles.length} file(s) saved to ${_selectedPatient!.name}',
          AppColors.success,
        );
        setState(() => _pickedFiles.clear());
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _removeFile(PlatformFile f) => setState(() => _pickedFiles.remove(f));

  void _previewFile(PlatformFile f) {
    if (f.bytes == null) return;
    final lower = f.name.toLowerCase();
    final isImage = lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.bmp');
    if (isImage) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(f.name,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Image.memory(f.bytes!, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      );
    } else {
      // Download for preview
      final blob = html.Blob([f.bytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', f.name)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  IconData _icon(String name) {
    final l = name.toLowerCase();
    if (l.endsWith('.stl') || l.endsWith('.obj') || l.endsWith('.ply')) {
      return Icons.view_in_ar_rounded;
    }
    if (l.endsWith('.jpg') || l.endsWith('.jpeg') ||
        l.endsWith('.png') || l.endsWith('.bmp')) {
      return Icons.image_rounded;
    }
    if (l.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (l.endsWith('.zip')) return Icons.folder_zip_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _sizeLabel(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final patients = _myPatients(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Files',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step 1: Select Patient
            _SectionCard(
              step: '1',
              title: 'Select Patient',
              icon: Icons.person_search_rounded,
              iconColor: AppColors.accent,
              child: patients.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No patients assigned to you.',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    )
                  : Column(
                      children: patients.map((p) {
                        final selected = _selectedPatient?.patientId == p.patientId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPatient = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.gray100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(p.name[0].toUpperCase(),
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary)),
                                      Text(
                                          '${p.age} yrs · ${p.gender} · ${p.chiefComplaint}',
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10,
                                              color: AppColors.textTertiary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ]),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 20),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 14),

            // ── Step 2: Pick Files
            _SectionCard(
              step: '2',
              title: 'Select Files',
              icon: Icons.attach_file_rounded,
              iconColor: AppColors.info,
              child: Column(children: [
                // Picked files list
                if (_pickedFiles.isNotEmpty) ...[
                  ..._pickedFiles.map((f) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.info.withOpacity(0.25)),
                    ),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => _previewFile(f),
                        child: Icon(_icon(f.name),
                            size: 20, color: AppColors.info),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis),
                              Text(_sizeLabel(f.size),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: AppColors.textTertiary)),
                            ]),
                      ),
                      GestureDetector(
                        onTap: () => _removeFile(f),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textTertiary),
                      ),
                    ]),
                  )),
                  const SizedBox(height: 8),
                ],

                // Add files button
                GestureDetector(
                  onTap: _isPicking ? null : _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isPicking ? AppColors.info : AppColors.border,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _isPicking
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.info)),
                              SizedBox(width: 10),
                              Text('Opening file picker…',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: AppColors.info)),
                            ],
                          )
                        : Column(children: [
                            Icon(Icons.upload_file_rounded,
                                size: 36, color: AppColors.info),
                            const SizedBox(height: 8),
                            const Text('Tap to browse files',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.info)),
                            const SizedBox(height: 4),
                            const Text(
                                'STL · OBJ · PLY · JPG · PNG · PDF · DICOM',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    color: AppColors.textTertiary)),
                          ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Step 3: Save
            _SectionCard(
              step: '3',
              title: 'Save to Patient Record',
              icon: Icons.save_rounded,
              iconColor: AppColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPatient != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.person_rounded,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_pickedFiles.length} file(s) → ${_selectedPatient!.name}',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success),
                          ),
                        ),
                      ]),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isSaving || _selectedPatient == null ||
                              _pickedFiles.isEmpty)
                          ? null
                          : _saveToPatient,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_rounded, size: 18),
                      label: Text(
                          _isSaving
                              ? 'Saving…'
                              : 'Save ${_pickedFiles.length} File(s) to Patient',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.success.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String step, title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _SectionCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                  color: iconColor, shape: BoxShape.circle),
              child: Center(
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          child,
        ]),
      );
}
