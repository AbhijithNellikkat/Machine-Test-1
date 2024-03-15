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
