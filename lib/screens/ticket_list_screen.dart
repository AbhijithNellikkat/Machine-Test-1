import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:machine_test1/screens/ticketDetails_screen.dart';
import 'package:machine_test1/screens/ticket_form_screen.dart';
import 'package:machine_test1/services/firestore_service.dart';
import 'package:machine_test1/services/notification_service.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final FireStoreServices fireStoreServices = FireStoreServices();

  final NotificationService notificationService = NotificationService();

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("Tickets");

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
   
    notificationService.getDeviceToken().then((value) {
      log("Device Token : $value");
    });
  }

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
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No data available');
          } else {
            log('Received ${snapshot.data!.docs.length} documents');
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final ticket = snapshot.data!.docs[index];
                return ListTile(
                    leading: const CircleAvatar(),
                    title: Text(ticket['title']),
                    subtitle: Text(ticket['description']),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            TicketDetailsScreen(ticket: ticket),
                      ));
                    });
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
