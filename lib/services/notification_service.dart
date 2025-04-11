import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'stock_alerts', // ID del canal
  'Stock Alerts', // Nombre del canal
  description: 'Este canal es para notificaciones de stock bajo',
  importance: Importance.max,
);

// Handler para segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> initNotifications() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('splash_logo');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
  await _requestPermissions();

  await FirebaseMessaging.instance.requestPermission();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      showNotifications(
        title: message.notification!.title ?? 'Sin título',
        body: message.notification!.body ?? 'Sin contenido',
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  } else if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

Future<void> showNotifications({
  required String title,
  required String body,
  int id = 0,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'stock_alerts',
    'Stock Alerts',
    channelDescription: 'Este canal es para notificaciones de stock bajo',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
  );
}

// Verificación de stock bajo en Firestore
Future<void> verificarStockBajo() async {
  try {
    final productosSnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    for (var doc in productosSnapshot.docs) {
      final data = doc.data();
      final nombre = data['producto'] ?? 'Producto sin nombre';
      final stockString = data['stock'] ?? '0';
      final stock = int.tryParse(stockString);

      if (stock != null && stock < 5) {
        await showNotifications(
          title: 'Stock bajo',
          body: 'El producto "$nombre" tiene solo $stock unidades',
          id: doc.id.hashCode,
        );
      }
    }
  } catch (e) {}
}
