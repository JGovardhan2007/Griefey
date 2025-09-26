import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class EditGrievanceScreen extends StatefulWidget {
  final String grievanceId;

  const EditGrievanceScreen({super.key, required this.grievanceId});

  @override
  State<EditGrievanceScreen> createState() => _EditGrievanceScreenState();
}

class _EditGrievanceScreenState extends State<EditGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _category;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrievanceData();
  }

  Future<void> _loadGrievanceData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('grievances')
          .doc(widget.grievanceId)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _titleController = TextEditingController(text: data['title']);
          _descriptionController = TextEditingController(text: data['description']);
          _category = data['category'];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateGrievance() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('grievances')
            .doc(widget.grievanceId)
            .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _category,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grievance updated successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update grievance: $e')),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Grievance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Technical', 'Billing', 'General']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateGrievance,
                      child: _isLoading
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text('Update Grievance'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
