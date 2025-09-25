import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class SubmitGrievanceScreen extends StatefulWidget {
  const SubmitGrievanceScreen({super.key});

  @override
  State<SubmitGrievanceScreen> createState() => _SubmitGrievanceScreenState();
}

class _SubmitGrievanceScreenState extends State<SubmitGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Roads',
    'Electricity',
    'Water',
    'Health',
    'Sanitation',
    'Public Transport',
    'Other',
  ];

  XFile? _imageFile;
  bool _isUploading = false;
  bool _isFetchingLocation = false;
  Position? _currentPosition;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  Future<String?> _uploadFile(String grievanceId) async {
    if (_imageFile == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child(
      'grievances/${user.uid}/$grievanceId/$fileName',
    );

    try {
      if (kIsWeb) {
        await storageRef.putData(await _imageFile!.readAsBytes());
      } else {
        await storageRef.putFile(File(_imageFile!.path));
      }
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitGrievance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    try {
      DocumentReference grievanceRef = FirebaseFirestore.instance
          .collection('grievances')
          .doc();

      String? fileUrl = await _uploadFile(grievanceRef.id);

      GeoPoint? locationPoint;
      if (_currentPosition != null) {
        locationPoint = GeoPoint(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      await grievanceRef.set({
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'status': 'Pending', 
        'submittedAt': FieldValue.serverTimestamp(),
        'imageUrl': fileUrl,
        'location': locationPoint,
        'history': [
          {
            'status': 'Pending',
            'timestamp': Timestamp.now(),
            'notes': 'Grievance submitted by citizen.',
          },
        ],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grievance submitted successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit grievance: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Submit a Grievance'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: _isUploading
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting Grievance...'),
                ],
              ))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Pothole on Main Street',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Provide details about the issue...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Attach Photo (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ],
                      ),
                      if (_imageFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: kIsWeb
                              ? Image.network(_imageFile!.path, height: 150)
                              : Image.file(File(_imageFile!.path), height: 150),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isFetchingLocation
                          ? const Center(child: CircularProgressIndicator())
                          : _currentPosition == null
                              ? OutlinedButton.icon(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Auto-Detect Location'),
                                )
                              : ListTile(
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.blue,
                                    ),
                                    onPressed: _getCurrentLocation,
                                    tooltip: 'Refresh Location',
                                  ),
                                ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitGrievance,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 8,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        child: const Text('Submit Grievance'),
                      ),
                    ],
                  ),
                )));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
