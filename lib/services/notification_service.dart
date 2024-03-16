// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen(
      (message) {
        // log("Message Title : ${message.notification!.title}");
        // log("Message Body : ${message.notification!.body}");

        if (Platform.isAndroid) {
          initLocalNotification(context, message);
          showNotification(message);
        }
      },
    );
  }

  Future<void> initLocalNotification(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitializationsettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitializationsettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted provisional permission");
    } else {
      AppSettings.openNotificationSettings();
      print("user denied permission");
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<void> isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
    print("Token Refresh");
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notification',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      notificationChannel.id.toString(),
      notificationChannel.name.toString(),
      channelDescription: 'channelDescription',
      importance: Importance.high,
      ticker: 'ticker',
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(
      Duration.zero,
      () {
        flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            notificationDetails);
      },
    );
  }
}
