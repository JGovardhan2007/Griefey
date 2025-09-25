import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/hover_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _selectedStatusFilter = 'All';
  String _sortOrder = 'desc';

  void _showUpdateStatusDialog(
      BuildContext context, DocumentSnapshot grievance) {
    final noteController = TextEditingController();
    String selectedStatus = grievance['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Grievance Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: [
                      'Pending',
                      'In-Progress',
                      'Resolved'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await _updateGrievanceStatus(
                  grievance.id,
                  selectedStatus,
                  noteController.text.trim(),
                );

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Grievance updated successfully!'),
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateGrievanceStatus(
      String grievanceId, String newStatus, String note) async {
    final grievanceRef = FirebaseFirestore.instance
        .collection('grievances')
        .doc(grievanceId);

    final newHistoryEntry = {
      'status': newStatus,
      'timestamp': FieldValue.serverTimestamp(),
      'notes':
          note.isNotEmpty ? note : 'Status updated to $newStatus by admin.',
    };

    await grievanceRef.update({
      'status': newStatus,
      'history': FieldValue.arrayUnion([newHistoryEntry]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.go('/');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('grievances').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No grievances found.'));
              }

              final grievances = snapshot.data!.docs;

              return Column(
                children: [
                  _buildCharts(grievances, theme),
                  _buildFilterAndSort(theme),
                  Expanded(
                    child: _buildGrievanceList(grievances, theme),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildCharts(List<DocumentSnapshot> grievances, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryPieChart(grievances, theme),
          ),
          Expanded(
            child: _buildStatusPieChart(grievances, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(
      List<DocumentSnapshot> grievances, ThemeData theme) {
    final categoryCounts = <String, int>{};
    for (var grievance in grievances) {
      final category = grievance['category'] as String? ?? 'Other';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final pieChartSections = categoryCounts.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key, theme),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          const Text('Grievances by Category', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(List<DocumentSnapshot> grievances, ThemeData theme) {
    final statusCounts = <String, int>{};
    for (var grievance in grievances) {
      final status = grievance['status'] as String? ?? 'Pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final pieChartSections = statusCounts.entries.map((entry) {
      return PieChartSectionData(
        color: _getStatusColor(entry.key, theme),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          const Text('Grievances by Status', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSort(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _selectedStatusFilter,
            items: ['All', 'Pending', 'In-Progress', 'Resolved'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatusFilter = newValue;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(_sortOrder == 'desc'
                ? Icons.arrow_downward
                : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrievanceList(
      List<DocumentSnapshot> grievances, ThemeData theme) {
    List<DocumentSnapshot> filteredGrievances = grievances;
    if (_selectedStatusFilter != 'All') {
      filteredGrievances = grievances
          .where((g) => g['status'] == _selectedStatusFilter)
          .toList();
    }

    filteredGrievances.sort((a, b) {
      final aDate = (a['submittedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bDate = (b['submittedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
      return _sortOrder == 'desc' ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: filteredGrievances.length,
      itemBuilder: (context, index) {
        final grievance = filteredGrievances[index];
        final data = grievance.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'Pending';

        return HoverCard(
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 4.0,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: _getStatusIcon(status, theme),
              title: Text(
                data['title'] ?? 'No Title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    data['category'] ?? 'No Category',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Submitted: ${data['submittedAt'] != null ? DateFormat.yMMMd().add_jm().format((data['submittedAt'] as Timestamp).toDate()) : 'Not available'}'),
                ],
              ),
              trailing: _getStatusChip(status, theme),
              onTap: () {
                _showUpdateStatusDialog(context, grievance);
              },
            ),
          ),
        );
      },
    );
  }

  Icon _getStatusIcon(String status, ThemeData theme) {
    switch (status) {
      case 'Resolved':
        return Icon(Icons.check_circle, color: Colors.green[600], size: 40);
      case 'In-Progress':
        return Icon(Icons.hourglass_bottom, color: Colors.blue[600], size: 40);
      case 'Pending':
      default:
        return Icon(Icons.info, color: Colors.orange[600], size: 40);
    }
  }

  Widget _getStatusChip(String status, ThemeData theme) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(color: _getStatusTextColor(status), fontWeight: FontWeight.bold),
      ),
      backgroundColor: _getStatusColor(status, theme).withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  Color _getCategoryColor(String category, ThemeData theme) {
    // Use a hash function to get a consistent color for each category
    return Colors.primaries[category.hashCode % Colors.primaries.length];
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In-Progress':
        return Colors.blue;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[800]!;
      case 'In-Progress':
        return Colors.blue[800]!;
      case 'Pending':
      default:
        return Colors.orange[800]!;
    }
  }
}
