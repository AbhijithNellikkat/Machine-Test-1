import 'package:flutter/material.dart';
import 'package:machine_test1/services/firestore_service.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({Key? key}) : super(key: key);

  @override
  _TicketFormScreenState createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();

  final FireStoreServices fireStoreServices = FireStoreServices();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _attachmentController,
              decoration: InputDecoration(labelText: 'Attachment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {},
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
