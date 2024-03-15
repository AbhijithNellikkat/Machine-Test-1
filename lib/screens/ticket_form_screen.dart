import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

  Position? currentLocation;
  // late bool servicePermission = false;
  // late LocationPermission permission;

  String currentAddress = "demo";

  bool isLoading = true;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true; // Set isLoading to true when fetching location
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
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";

        _locationController.text = currentAddress; // Update location text field
        setState(() {
          isLoading =
              false; // Set isLoading to false after location is fetched and text field is updated
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      DateTime now = DateTime.now();

      final data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "location":
            _locationController.text, // Make sure location is added here
        "reportedDate": now,
        "attachmentUrl": _attachmentController.text
      };

      await collectionReference.add(data);

      log("New Ticket is Created");

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

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
                OutlinedButton(
                  onPressed: () async {
                    await getCurrentLocation();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                    child: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _attachmentController,
                  decoration: const InputDecoration(labelText: 'Attachment'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an attachment';
                    }
                    return null;
                  },
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
