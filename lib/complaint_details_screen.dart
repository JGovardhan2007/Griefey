import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String grievanceId;

  const ComplaintDetailsScreen({super.key, required this.grievanceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Grievance Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('grievances')
            .doc(grievanceId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Grievance not found.'));
          }

          final grievance = snapshot.data!.data() as Map<String, dynamic>;
          final status = grievance['status'] ?? 'Pending';
          final history = (grievance['history'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        grievance['title'] ?? 'No Title',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _getStatusChip(status, theme),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${grievance['category'] ?? 'N/A'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withAlpha(204), // 80% opacity
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submitted: ${DateFormat.yMMMd().add_jm().format((grievance['submittedAt'] as Timestamp).toDate())}',
                  style: theme.textTheme.bodySmall,
                ),
                const Divider(height: 32),

                // Description
                Text(
                  'Description',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  grievance['description'] ?? 'No description provided.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Attached File
                if (grievance['fileUrl'] != null) ...[
                  Text(
                    'Attachment',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse(grievance['fileUrl']);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Could not open the attachment.'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'View Attached File',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Location
                if (grievance['location'] != null) ...[
                  Text(
                    'Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lat: ${grievance['location'].latitude}, Lon: ${grievance['location'].longitude}',
                  ),
                  const SizedBox(height: 24),
                ],

                // Status History / Timeline
                Text(
                  'History & Updates',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...history.map((entry) {
                  final entryData = entry as Map<String, dynamic>;
                  return _buildHistoryTile(entryData, theme);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> entry, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                _getStatusIcon(entry['status']),
                color: _getStatusColor(entry['status']),
              ),
              Container(
                height: 40,
                width: 2,
                color: _getStatusColor(entry['status']).withAlpha(128), // 50% opacity
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['status'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().add_jm().format(
                    (entry['timestamp'] as Timestamp).toDate(),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(entry['notes'] ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle;
      case 'In-Progress':
        return Icons.hourglass_bottom;
      case 'Pending':
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[600]!;
      case 'In-Progress':
        return Colors.blue[600]!;
      case 'Pending':
      default:
        return Colors.orange[600]!;
    }
  }

  Widget _getStatusChip(String status, ThemeData theme) {
    Color chipColor;
    Color textColor;
    switch (status) {
      case 'Resolved':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'In-Progress':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'Pending':
      default:
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
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