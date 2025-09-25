import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GrievanceDetailsScreen extends StatelessWidget {
  final String grievanceId;

  const GrievanceDetailsScreen({super.key, required this.grievanceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grievance Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
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
                return Center(
                  child: Text('Something went wrong: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Grievance not found.'));
              }

              final grievance = snapshot.data!;
              final data = grievance.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'No Title',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          data['category'] ?? 'No Category',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const Spacer(),
                        _getStatusChip(data['status'] ?? 'Pending', theme),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      theme,
                      icon: Icons.calendar_today,
                      label: 'Submitted',
                      value: data['submittedAt'] != null
                          ? DateFormat.yMMMd()
                              .add_jm()
                              .format((data['submittedAt'] as Timestamp).toDate())
                          : 'Not available',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      theme,
                      icon: Icons.description,
                      label: 'Description',
                      value: data['description'] ?? 'No description provided.',
                    ),
                    if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attached Image',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                data['imageUrl'],
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red, size: 50);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Status History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryTimeline(data['history'] ?? [], theme),
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('grievances').doc(grievanceId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // Hide button while loading
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final bool isOwner = data['userId'] == currentUser?.uid;
          final bool isPending = data['status'] == 'Pending';

          if (isOwner && isPending) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.go('/edit_grievance/$grievanceId');
              },
              label: const Text('Edit Grievance'),
              icon: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTimeline(List<dynamic> history, ThemeData theme) {
    if (history.isEmpty) {
      return const Text('No history available.');
    }

    history.sort((a, b) {
      final timestampA = a['timestamp'] as Timestamp? ?? Timestamp(0, 0);
      final timestampB = b['timestamp'] as Timestamp? ?? Timestamp(0, 0);
      return timestampB.compareTo(timestampA);
    });

    return Column(
      children: history.asMap().entries.map((entry) {
        int index = entry.key;
        var event = entry.value;
        bool isFirst = index == 0;
        bool isLast = index == history.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: isFirst,
          isLast: isLast,
          beforeLineStyle: LineStyle(color: Colors.grey.shade400),
          indicatorStyle: IndicatorStyle(
            width: 40,
            height: 40,
            indicator: Container(
              decoration: BoxDecoration(
                color: _getStatusColor(event['status'] ?? '', theme),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(event['status'] ?? ''),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['status'] ?? 'Unknown Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(event['status'] ?? '', theme),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['timestamp'] != null
                      ? DateFormat.yMMMd().add_jm().format((event['timestamp'] as Timestamp).toDate())
                      : 'No date',
                  style: theme.textTheme.bodySmall,
                ),
                if (event['notes'] != null && event['notes'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      event['notes'],
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_outline;
      case 'In-Progress':
        return Icons.hourglass_bottom;
      case 'Pending':
      default:
        return Icons.info_outline;
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
