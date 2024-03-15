

import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String title;
  final String description;
  final String location;
  final Timestamp reportedDate;
  final String attachmentUrl;

  Ticket({
    required this.title,
    required this.description,
    required this.location,
    required this.reportedDate,
    required this.attachmentUrl,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      title: json['title'],
      description: json['description'],
      location: json['location'],
      reportedDate: json['reportedDate'].toDate(),
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'reportedDate': reportedDate,
      'attachmentUrl': attachmentUrl,
    };
  }
}
