import 'package:flutter/material.dart';

enum GrievanceStatus { Pending, InProgress, Resolved }

class Grievance {
  final String id;
  final String title;
  final String category;
  final String description;
  final GrievanceStatus status;
  final DateTime submittedDate;

  Grievance({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.submittedDate,
  });
}
