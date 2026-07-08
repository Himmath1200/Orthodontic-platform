import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_model.dart';
import '../providers/auth_provider.dart';
import '../providers/mock_providers.dart';
import '../widgets/custom_widgets.dart';

class NewCaseScreen extends StatefulWidget {
  const NewCaseScreen({Key? key}) : super(key: key);

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _caseTitleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    _patientNameController.dispose();
    _caseTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreateCase() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final caseProvider = context.read<MockCaseProvider>();

      if (authProvider.currentUser != null) {
        final newCase = CaseModel(
          caseId: 'case_${DateTime.now().millisecondsSinceEpoch}',
          userId: authProvider.currentUser!.uid,
          patientId: 'patient_${DateTime.now().millisecondsSinceEpoch}',
          patientName: _patientNameController.text.trim(),
          caseTitle: _caseTitleController.text.trim(),
          status: CaseStatus.active,
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await caseProvider.createCase(newCase);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Case created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Case'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID',
                    hintText: 'Enter patient ID',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Patient ID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    hintText: 'Enter patient name',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Patient name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caseTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Case Title',
                    hintText: 'Enter case title',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Case title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter case description',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                Consumer<MockCaseProvider>(
                  builder: (context, caseProvider, _) {
                    return PrimaryButton(
                      text: 'Create Case',
                      onPressed: _handleCreateCase,
                      isLoading: caseProvider.isLoading,
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
