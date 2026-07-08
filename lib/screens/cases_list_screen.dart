import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/mock_providers.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({Key? key}) : super(key: key);

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCases();
    });
  }

  void _loadCases() {
    final authProvider = context.read<AuthProvider>();
    final caseProvider = context.read<MockCaseProvider>();

    if (authProvider.currentUser != null) {
      caseProvider.fetchUserCases();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/new-case');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<MockCaseProvider>(
        builder: (context, caseProvider, _) {
          if (caseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (caseProvider.cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No cases yet', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new case to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/new-case');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Case'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: caseProvider.cases.length,
            itemBuilder: (context, index) {
              final caseItem = caseProvider.cases[index];
              return _CaseCard(caseItem: caseItem);
            },
          );
        },
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final CaseModel caseItem;

  const _CaseCard({required this.caseItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/case-detail', arguments: caseItem.caseId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caseItem.caseTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${caseItem.patientId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Patient: ${caseItem.patientName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${caseItem.status.toString().split('.').last}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'STL Files: ${caseItem.stlFileIds.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Analyses: ${caseItem.totalAnalyses}',
                    style: Theme.of(context).textTheme.bodySmall,
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
