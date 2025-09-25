import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'submit_grievance_service.dart';

class SubmitGrievanceScreen extends StatefulWidget {
  const SubmitGrievanceScreen({super.key});

  @override
  State<SubmitGrievanceScreen> createState() => _SubmitGrievanceScreenState();
}

class _SubmitGrievanceScreenState extends State<SubmitGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _category = ValueNotifier<String?>(null);
  final _imageFile = ValueNotifier<XFile?>(null);
  final _location = ValueNotifier<Position?>(null);
  final _isSubmitting = ValueNotifier<bool>(false);

  final _categories = [
    'Roads', 'Electricity', 'Water', 'Health',
    'Sanitation', 'Public Transport', 'Other'
  ];

  late final SubmitGrievanceService _grievanceService;

  @override
  void initState() {
    super.initState();
    _grievanceService = SubmitGrievanceService();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    _isSubmitting.value = true;

    try {
      final imageUrl = await _grievanceService.uploadFile(
        _imageFile.value,
        _titleController.text, // Using title for a more descriptive path
      );

      final grievanceId = await _grievanceService.submitGrievance(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category.value!,
        imageUrl: imageUrl,
        location: _location.value,
      );

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Grievance Submitted'),
            content: Text('Your grievance has been submitted successfully.\n\nToken ID: $grievanceId'),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Grievance'),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isSubmitting,
        builder: (context, isSubmitting, child) {
          return isSubmitting
              ? const _LoadingIndicator(message: 'Submitting Grievance...')
              : child!;
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionCard(
                title: 'Grievance Details',
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => v!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => _category.value = v,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => v == null ? 'Category is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 5,
                    validator: (v) => v!.isEmpty ? 'Description is required' : null,
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Attachments',
                children: [
                  _ImagePickerSection(imageFile: _imageFile, service: _grievanceService),
                  const SizedBox(height: 16),
                  _LocationPickerSection(location: _location, service: _grievanceService),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Grievance'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _category.dispose();
    _imageFile.dispose();
    _location.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({required this.imageFile, required this.service});

  final ValueNotifier<XFile?> imageFile;
  final SubmitGrievanceService service;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<XFile?>(
      valueListenable: imageFile,
      builder: (context, file, child) {
        return Column(
          children: [
            if (file != null)
              kIsWeb
                  ? Image.network(file.path, height: 150)
                  : Image.file(File(file.path), height: 150),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async => imageFile.value = await service.pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () async => imageFile.value = await service.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LocationPickerSection extends StatelessWidget {
  const _LocationPickerSection({required this.location, required this.service});

  final ValueNotifier<Position?> location;
  final SubmitGrievanceService service;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Position?>(
      valueListenable: location,
      builder: (context, pos, child) {
        if (pos != null) {
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: Text('Lat: ${pos.latitude.toStringAsFixed(5)}, Lon: ${pos.longitude.toStringAsFixed(5)}'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: () async => location.value = await service.getCurrentLocation(),
            ),
          );
        }
        return OutlinedButton.icon(
          onPressed: () async => location.value = await service.getCurrentLocation(),
          icon: const Icon(Icons.my_location),
          label: const Text('Get Location'),
        );
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
