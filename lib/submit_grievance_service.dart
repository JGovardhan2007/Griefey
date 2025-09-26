import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class SubmitGrievanceService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are permanently denied.');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  String createGrievanceId() {
    return _firestore.collection('grievances').doc().id;
  }

  Future<String?> uploadFile(XFile? imageFile, String grievanceId) async {
    if (imageFile == null) return null;

    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref('grievances/${user.uid}/$grievanceId/$fileName');

    if (kIsWeb) {
      await storageRef.putData(await imageFile.readAsBytes());
    } else {
      await storageRef.putFile(File(imageFile.path));
    }
    return await storageRef.getDownloadURL();
  }

  Future<void> submitGrievance({
    required String grievanceId,
    required String title,
    required String description,
    required String category,
    required String? imageUrl,
    required Position? location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final grievanceRef = _firestore.collection('grievances').doc(grievanceId);

    GeoPoint? geoPoint;
    if (location != null) {
      geoPoint = GeoPoint(location.latitude, location.longitude);
    }

    await grievanceRef.set({
      'userId': user.uid,
      'title': title,
      'description': description,
      'category': category,
      'status': 'Pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'location': geoPoint,
      'history': [
        {
          'status': 'Pending',
          'timestamp': Timestamp.now(),
          'notes': 'Grievance submitted by citizen.',
        },
      ],
    });
  }
}
