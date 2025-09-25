import 'package:flutter/material.dart';
import 'package:myapp/models/grievance.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String grievanceId;

  const ComplaintDetailsScreen({super.key, required this.grievanceId});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch the grievance details from a database
    // using the grievanceId. For now, we'll use mock data.
    final Grievance grievance = Grievance(
      id: grievanceId,
      title: 'Pothole on Main Street',
      category: 'Roads',
      description: 'A large pothole is causing traffic issues.',
      status: GrievanceStatus.Pending,
      submittedDate: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              grievance.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text('Category: ${grievance.category}'),
            const SizedBox(height: 10),
            Text(grievance.description),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Status: '),
                Chip(
                  label: Text(grievance.status.toString().split('.').last),
                  backgroundColor: getStatusColor(grievance.status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}
