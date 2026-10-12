import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef TokenHandler = Future<void> Function(String token);
typedef RouteHandler = void Function(String route);

final _localNotifications = FlutterLocalNotificationsPlugin();

String maskToken(String token) {
  if (token.length <= 12) return '***';
  return '${token.substring(0, 12)}...';
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _localNotifications.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
  );
  const channel = AndroidNotificationChannel(
    'campus_notify_channel',
    'Campus Notify',
    description: 'Notifikasi pengumuman Campus Notify',
    importance: Importance.high,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showForegroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'campus_notify_channel',
      'Campus Notify',
      channelDescription: 'Notifikasi pengumuman Campus Notify',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );
  await _localNotifications.show(
    id: message.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: details,
    payload: message.data['route'] as String?,
  );
}

Future<StreamSubscription<String>> initFcmToken({
  required TokenHandler onToken,
  TokenHandler? onTokenRefresh,
  Future<String?> Function()? getToken,
  Stream<String>? tokenRefresh,
  Future<void> Function(String topic)? subscribeToTopic,
  String topic = 'pengumuman-kampus',
}) async {
  final fetch = getToken ?? FirebaseMessaging.instance.getToken;
  final refresh = tokenRefresh ?? FirebaseMessaging.instance.onTokenRefresh;
  final subscribe = subscribeToTopic ??
      FirebaseMessaging.instance.subscribeToTopic;

  final token = await fetch();
  if (token != null) await onToken(token);
  final subscription = refresh.listen(onTokenRefresh ?? onToken);
  await subscribe(topic);
  return subscription;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushService {
  PushService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? notifications,
  })  : _messagingOverride = messaging,
        _notifications =
            notifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging? _messagingOverride;
  final FlutterLocalNotificationsPlugin _notifications;
  late final FirebaseMessaging _messaging;

  Future<String?> initialize({
    TokenHandler? onToken,
    RouteHandler? onRoute,
  }) async {
    try {
      await Firebase.initializeApp();
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') return null;
    }

    _messaging = _messagingOverride ?? FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await _initializeLocalNotifications(onRoute);
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    final token = await _messaging.getToken();
    if (token != null && onToken != null) await onToken(token);
    _messaging.onTokenRefresh.listen((value) async {
      if (onToken != null) await onToken(value);
    });

    FirebaseMessaging.onMessage.listen(
      (message) => _showForegroundNotification(message, onRoute),
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleRoute(message, onRoute),
    );

    final initialMessage = await _messaging.getInitialMessage();
    return initialMessage == null
        ? null
        : _routeFromMessage(initialMessage);
  }

  Future<void> _initializeLocalNotifications(RouteHandler? onRoute) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.startsWith('/')) onRoute?.call(route);
      },
    );

    const channel = AndroidNotificationChannel(
      'campus_notify_channel',
      'Campus Notify',
      description: 'Notifikasi pengumuman Campus Notify',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(
    RemoteMessage message,
    RouteHandler? onRoute,
  ) async {
    final notification = message.notification;
    if (notification == null) return;

    final route = _routeFromMessage(message);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'campus_notify_channel',
        'Campus Notify',
        channelDescription: 'Notifikasi pengumuman Campus Notify',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: route,
    );
  }

  void _handleRoute(RemoteMessage message, RouteHandler? onRoute) {
    final route = _routeFromMessage(message);
    if (route != null) onRoute?.call(route);
  }

  String? _routeFromMessage(RemoteMessage message) {
    final route = message.data['route'];
    return route is String && route.startsWith('/') ? route : null;
  }
}
