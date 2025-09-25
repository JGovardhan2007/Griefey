import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:myapp/hover_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdmin = false;
  final ValueNotifier<bool> _isFabHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true); // Force refresh
      setState(() {
        _isAdmin = idTokenResult.claims?['admin'] == true;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grievances'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                context.go('/admin');
              },
              tooltip: 'Admin Dashboard',
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.go('/profile');
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('grievances')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('submittedAt', descending: true)
            .snapshots(),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/griefey_logo.png', height: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No grievances yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the button below to submit your first one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final grievances = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: grievances.length,
            itemBuilder: (context, index) {
              final grievance = grievances[index];
              final data = grievance.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Pending';

              return HoverCard(
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => context.go('/details/${grievance.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _buildGrievanceImage(data, theme),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? 'No Title',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['category'] ?? 'No Category',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withAlpha(204)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Submitted: ${DateFormat.yMMMd().add_jm().format((data['submittedAt'] as Timestamp).toDate())}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          _getStatusChip(status, theme),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => _isFabHovered.value = true,
        onExit: (_) => _isFabHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isFabHovered,
          builder: (context, isHovered, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.1 : 1.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.go('/submit');
                },
                label: const Text('Submit Grievance'),
                icon: const Icon(Icons.add),
                elevation: 8,
                highlightElevation: 16,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrievanceImage(Map<String, dynamic> data, ThemeData theme) {
    final imageUrl = data['imageUrl'] as String?;
    final status = data['status'] ?? 'Pending';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _getStatusIcon(status, theme);
                },
              )
            : _getStatusIcon(status, theme),
      ),
    );
  }

  Widget _getStatusIcon(String status, ThemeData theme) {
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
