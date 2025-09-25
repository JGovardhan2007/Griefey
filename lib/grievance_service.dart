import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class for handling grievance-related Firestore operations.
class GrievanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// A stream of grievances submitted by the current user.
  ///
  /// The stream provides real-time updates on the user's grievances,
  /// ordered by submission date.
  Stream<QuerySnapshot> watchUserGrievances() {
    final user = _auth.currentUser;
    if (user == null) {
      // If the user is not logged in, return an empty stream.
      // The UI layer should handle this case gracefully.
      return const Stream.empty();
    }

    return _firestore
        .collection('grievances')
        .where('userId', isEqualTo: user.uid)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  /// A stream of all grievances, intended for admin use.
  ///
  /// This stream provides real-time updates on all grievances in the system,
  /// ordered by submission date.
  Stream<QuerySnapshot> watchAllGrievances() {
    return _firestore
        .collection('grievances')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
}
