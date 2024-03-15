import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:machine_test1/screens/ticket_form_screen.dart';
import 'package:machine_test1/services/firestore_service.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final FireStoreServices fireStoreServices = FireStoreServices();

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("datas");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket List'),
      ),
      body: StreamBuilder(
        stream: collectionReference.snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show loading indicator while waiting for data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No data available');
          } else {
            log('Received ${snapshot.data!.docs.length} documents'); // Print number of documents received
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final ticket = snapshot.data!.docs[index];
                return Text(ticket['title']);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const TicketFormScreen(),
          ));
        },
      ),
    );
  }
}
