import 'package:flutter/material.dart';

class CaseDetailScreen extends StatelessWidget {
  final String caseId;

  const CaseDetailScreen({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Case Details'),
            const SizedBox(height: 8),
            Text('Case ID: $caseId'),
          ],
        ),
      ),
    );
  }
}
