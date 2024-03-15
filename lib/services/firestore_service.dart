// ignore_for_file: constant_identifier_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

// const String TICKETS_COLLECTION_RFF = "Tickets";

class FireStoreServices {
  var datas = <Map<String, dynamic>>[];

  Future<void> fetchData() async {
    var snapshot = await FirebaseFirestore.instance.collection("Tickets").get();
    log("Datas :  ${snapshot.docs.length}");

    datas = snapshot.docs.map((doc) {
      var data = doc.data();

      log("$data");

      return data;
    }).toList();
  }
}


// late Position currentPosition;
  // String currentAddress = "My Address";

  // void getCurrentPosition() async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     Fluttertoast.showToast(
  //         msg:
  //             "Permission for accessing location is denied,Please go to settings and turn on");
  //     Geolocator.requestPermission();
  //   } else {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);

  //     try {
  //       List<Placemark> placemarks = await placemarkFromCoordinates(
  //           position.latitude, position.longitude);
  //       Placemark place = placemarks[0];
  //       setState(() {
  //         currentPosition = position;
  //         currentAddress =
  //             "${place.locality},${place.postalCode},${place.country}";
  //         _locationController.text = currentAddress;
  //         log(currentAddress);
  //       });
  //     } catch (e) {
  //       Fluttertoast.showToast(msg: e.toString());
  //     }
  //   }
  // }