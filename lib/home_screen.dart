import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/grievance.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Grievance> grievances = [
      Grievance(
        id: '1',
        title: 'Pothole on Main Street',
        category: 'Roads',
        description: 'A large pothole is causing traffic issues.',
        status: GrievanceStatus.Pending,
        submittedDate: DateTime.now(),
      ),
      Grievance(
        id: '2',
        title: 'Frequent Power Outages',
        category: 'Electricity',
        description: 'Power outages are happening almost daily.',
        status: GrievanceStatus.InProgress,
        submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Grievance(
        id: '3',
        title: 'Water leakage',
        category: 'Water',
        description: 'Water pipe leakage in the area.',
        status: GrievanceStatus.Resolved,
        submittedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    Color getStatusColor(GrievanceStatus status) {
      switch (status) {
        case GrievanceStatus.Pending:
          return Colors.yellow;
        case GrievanceStatus.InProgress:
          return Colors.blue;
        case GrievanceStatus.Resolved:
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Griefey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: grievances.length,
        itemBuilder: (context, index) {
          final grievance = grievances[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(grievance.title),
              subtitle: Text(grievance.category),
              trailing: Chip(
                label: Text(grievance.status.toString().split('.').last),
                backgroundColor: getStatusColor(grievance.status),
              ),
              onTap: () => context.go('/complaint-details/${grievance.id}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/submit-grievance'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
