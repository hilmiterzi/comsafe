import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'screens/test_notification_screen.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  
  if (message.data['type'] == 'call') {
    await NotificationService.instance.showCallNotification(
      callerName: message.data['caller_name'] ?? 'Unknown',
      callerId: message.data['caller_id'] ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'call') {
      NotificationService.instance.showCallNotification(
        callerName: message.data['caller_name'] ?? 'Unknown',
        callerId: message.data['caller_id'] ?? '',
      );
    }
  });

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken'); // Save this token for sending notifications

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Call Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TestNotificationScreen(),
    );
  }
}
