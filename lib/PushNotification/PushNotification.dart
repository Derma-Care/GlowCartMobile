// lib/services/notification_service.dart
import 'dart:io';

import 'package:cutomer_app/Notification/LocalNotification.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get/get.dart';

final _flutterLocal = FlutterLocalNotificationsPlugin();

/// ---------- BACKGROUND / TERMINATED ------------
@pragma('vm:entry-point') // <— needed so the VM keeps this symbol
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await _NotificationHelper._ensureInitialized();
  // _NotificationHelper.show(message);
}

/// ---------- PUBLIC API -------------------------
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final notificationController = Get.put(NotificationController());
  Future<void> init() async {
    // 1️⃣ Initialise Firebase background–handler (Android only)
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // 2️⃣ Ask for permission (iOS & Android 13+)
    await _NotificationHelper.requestUserPermission();

    // 3️⃣ Wire up listeners for every app‑state
    _setupListeners();

    // 4️⃣ Print (or send) FCM token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('📲 FCM Token: $token');
  }

  /* ------------------ INTERNAL ------------------ */
  void _setupListeners() async {
    // 🔹 Foreground
    FirebaseMessaging.onMessage.listen((msg) async {
      debugPrint('📥 Foreground: $msg');

      // 🔸 Show local notification banner
      if (msg.notification != null) {
        await _flutterLocal.show(
          0,
          msg.notification!.title ?? 'Notification',
          msg.notification!.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'general',
              'General',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }

      // ✅ Update controller & badge count in real time
      notificationController.handleNotification(msg);
    });

    // 🔹 Background ➜ foreground
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('📬 Opened from background: $msg');
      notificationController.handleNotification(msg);
    });

    // 🔹 Terminated ➜ launch
    final msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null) {
      debugPrint('🚀 Opened from quit state: $msg');
      notificationController.handleNotification(msg);
    }

    // 🔹 iOS presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

/// ---------- LOW‑LEVEL HELPER --------------------
class _NotificationHelper {
  static bool _initDone = false;

  /* Create 3 Android channels that match your RN version */
  static Future<void> _ensureInitialized() async {
    if (_initDone) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _flutterLocal.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Channels: general, appointment, critical
    await _createChannel(
      id: 'general',
      name: 'General',
      importance: Importance.defaultImportance,
    );
    await _createChannel(
      id: 'appointment',
      name: 'Appointments',
      importance: Importance.high,
    );
    await _createChannel(
      id: 'critical',
      name: 'Critical',
      importance: Importance.max,
    );

    _initDone = true;
  }

  static Future<void> _createChannel({
    required String id,
    required String name,
    required Importance importance,
    String? sound,
  }) async {
    final androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description: '$name notifications',
      importance: importance,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      playSound: sound != null,
    );

    await _flutterLocal
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  /* === Public helpers === */
  static Future<void> requestUserPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // mirrors AuthorizationStatus.PROVISIONAL
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('✅ Notification permission granted');
    }
  }
}
