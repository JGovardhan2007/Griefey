import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class GrievanceDetailsScreen extends StatelessWidget {
  final String grievanceId;

  const GrievanceDetailsScreen({super.key, required this.grievanceId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Grievance Details'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('grievances').doc(grievanceId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                _buildDetailItem('Title', data['title'] ?? 'N/A'),
                _buildDetailItem('Category', data['category'] ?? 'N/A'),
                _buildDetailItem('Status', data['status'] ?? 'N/A'),
                _buildDetailItem('Submitted', DateFormat.yMMMd().format((data['submittedAt'] as Timestamp).toDate())),
                const SizedBox(height: 16),
                if (data['imageUrl'] != null)
                  Image.network(data['imageUrl'], fit: BoxFit.cover),
                const SizedBox(height: 16),
                _buildDetailItem('Description', data['description'] ?? 'N/A'),
                const SizedBox(height: 24),
                // Admin section
                FutureBuilder<IdTokenResult?>(
                  future: authService.currentUser?.getIdTokenResult(),
                  builder: (context, idTokenSnapshot) {
                    if (idTokenSnapshot.connectionState == ConnectionState.done &&
                        idTokenSnapshot.hasData &&
                        idTokenSnapshot.data!.claims?['admin'] == true) {
                      return _AdminStatusUpdater(grievanceId: grievanceId, currentStatus: data['status']);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class _AdminStatusUpdater extends StatefulWidget {
  final String grievanceId;
  final String currentStatus;

  const _AdminStatusUpdater({required this.grievanceId, required this.currentStatus});

  @override
  State<_AdminStatusUpdater> createState() => _AdminStatusUpdaterState();
}

class _AdminStatusUpdaterState extends State<_AdminStatusUpdater> {
  String? _selectedStatus;
  final _notesController = TextEditingController();
  bool _isUpdating = false;

  final _statuses = ['Pending', 'In-Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _isUpdating = true);

    try {
      final grievanceRef = FirebaseFirestore.instance.collection('grievances').doc(widget.grievanceId);

      await grievanceRef.update({
        'status': _selectedStatus,
        'history': FieldValue.arrayUnion([
          {
            'status': _selectedStatus,
            'timestamp': Timestamp.now(),
            'notes': _notesController.text.trim(),
          }
        ])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated!')));
        context.pop(); // Go back to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Admin Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
          decoration: const InputDecoration(labelText: 'Update Status'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _isUpdating
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _updateStatus,
                child: const Text('Update Grievance'),
              ),
      ],
    );
  }
}
