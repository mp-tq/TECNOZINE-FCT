import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class NotificacionesService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> inicializarNotificaciones() async {
    // Inicialización de notificaciones locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Solicitar permisos en Android 13+ o iOS
    await _solicitarPermisos();

    // Token--------------------------------------------------------------------
    String? token = await _firebaseMessaging.getToken();
    print('Token de dispositivo: $token');
    // Notificaciones en primer plano-------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido: ${message.notification?.title}');
      _mostrarNotificacionLocal(message);
    });
  }

  Future<void> _solicitarPermisos() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission();
        print('Permiso concedido (Android): ${settings.authorizationStatus}');
      }
    } else if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission();
      print('Permiso concedido (iOS): ${settings.authorizationStatus}');
    }
  }

  // Mostrar notificación-------------------------------------------------------
  Future<void> _mostrarNotificacionLocal(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? message.data['title'] ?? 'Sin título',
      message.notification?.body ?? message.data['body'] ?? 'Sin cuerpo',
      platformDetails,
      payload: 'data',
    );
  }
}
