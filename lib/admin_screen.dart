import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'grievance_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grievanceService = GrievanceService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: StreamProvider<QuerySnapshot?>.value(
        value: grievanceService.watchAllGrievances(),
        initialData: null,
        child: const _AdminGrievanceList(),
      ),
    );
  }
}

class _AdminGrievanceList extends StatelessWidget {
  const _AdminGrievanceList();

  @override
  Widget build(BuildContext context) {
    final snapshot = Provider.of<QuerySnapshot?>(context);

    if (snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.docs.isEmpty) {
      return const Center(child: Text('No grievances have been submitted yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final grievance = snapshot.docs[index];
        return _AdminGrievanceCard(grievance: grievance);
      },
    );
  }
}

class _AdminGrievanceCard extends StatelessWidget {
  const _AdminGrievanceCard({required this.grievance});

  final QueryDocumentSnapshot grievance;

  @override
  Widget build(BuildContext context) {
    final data = grievance.data() as Map<String, dynamic>;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.go('/details/${grievance.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'] ?? 'No Title',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User: ${data['userId']}', // In a real app, you'd fetch the user's name
                    style: theme.textTheme.bodyMedium,
                  ),
                  _StatusChip(status: data['status'] ?? 'Pending'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Submitted: ${DateFormat.yMMMd().format((data['submittedAt'] as Timestamp).toDate())}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color chipColor;
    Color textColor;

    switch (status) {
      case 'Resolved':
        chipColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case 'In-Progress':
        chipColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
      case 'Pending':
      default:
        chipColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}
