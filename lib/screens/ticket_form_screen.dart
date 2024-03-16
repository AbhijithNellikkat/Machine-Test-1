import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:machine_test1/services/notification_service.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({Key? key}) : super(key: key);

  @override
  _TicketFormScreenState createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("Tickets");
  NotificationService notificationService = NotificationService();

  Position? currentLocation;
  late bool isLoading;
  late String? downloadLink;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              "Permission for accessing location is denied, Please go to settings and turn on");
      Geolocator.requestPermission();
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentLocation = position;
        _locationController.text =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> uploadPdf(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;
  }

  pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path ?? '');

      final link = await uploadPdf(fileName, file);

      String filePath = pickedFile.files.single.path!;

      setState(() {
        downloadLink = link;
        _attachmentController.text = filePath;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      DateTime now = DateTime.now();

      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "location": _locationController.text,
        "reportedDate": now,
        "attachmentUrl":
            downloadLink ?? '', // Handle the case if downloadLink is null
      };

      await collectionReference.add(data);

      log("New Ticket is Created");

      notificationService.getDeviceToken().then((value) async {
        var notificationMessage = {
          'to': value.toString(),
          'priority': 'high',
          'notification': {
            'title': _titleController.text,
            'body': _descriptionController.text,
          }
        };

        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(notificationMessage),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAnc3Zqjk:APA91bHOJGHYSubZeWjnvX2YbdXKuzuh0Uf7ggE6vuAUioVjWy4hNM7zdcqVAPFpX5MjMgfzN-eZcv-IonGakMLtF0FP85G4Jh2awUhDDLAL3kn28ofQNwO3l0_aoJrXVpFAVjtNJR70',
            });
      });
      Navigator.of(context).pop();
    }
  }

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: () async {
                          await getCurrentLocation();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 70, vertical: 10),
                          child: Icon(Icons.location_on),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _attachmentController,
                        decoration:
                            const InputDecoration(labelText: 'Attachment'),
                        enabled: true,
                      ),
                    ),
                    IconButton(
                      onPressed: pickFile,
                      icon: const Icon(Icons.attach_file),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
