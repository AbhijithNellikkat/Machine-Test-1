import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketDetailsScreen extends StatelessWidget {
  final DocumentSnapshot ticket;

  const TicketDetailsScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reportedDate = ticket['reportedDate'] as Timestamp;
    final formattedDate =
        DateFormat.yMMMMd().add_jm().format(reportedDate.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(ticket['description']),
            SizedBox(height: 10),
            Text(
              'Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(ticket['location']),
            SizedBox(height: 10),
            Text(
              'Reported Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(formattedDate),
            SizedBox(height: 10),
            const Text(
              'Attachment:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(ticket['attachmentUrl']),
          ],
        ),
      ),
    );
  }
}
