import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'grievance_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final grievanceService = GrievanceService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grievances'),
        actions: [
          // Admin check and button
          FutureBuilder<IdTokenResult?>(
            future: authService.currentUser?.getIdTokenResult(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final isAdmin = snapshot.data!.claims?['admin'] == true;
                if (isAdmin) {
                  return IconButton(
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => context.go('/admin'),
                    tooltip: 'Admin Dashboard',
                  );
                }
              }
              return const SizedBox.shrink(); // Show nothing while loading or if not admin
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamProvider<QuerySnapshot?>.value(
        value: grievanceService.watchUserGrievances(),
        initialData: null,
        child: const _GrievanceList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/submit'),
        label: const Text('Submit Grievance'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _GrievanceList extends StatelessWidget {
  const _GrievanceList();

  @override
  Widget build(BuildContext context) {
    final snapshot = Provider.of<QuerySnapshot?>(context);

    if (snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.docs.isEmpty) {
      return const _EmptyState();
    }

    final grievances = snapshot.docs;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: grievances.length,
      itemBuilder: (context, index) {
        final grievance = grievances[index];
        return _GrievanceCard(grievance: grievance);
      },
    );
  }
}

class _GrievanceCard extends StatelessWidget {
  const _GrievanceCard({required this.grievance});

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
                    data['category'] ?? 'No Category',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'No Grievances Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to submit your first one!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
