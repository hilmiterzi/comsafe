import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/calls_service.dart';

class TestNotificationScreen extends StatelessWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await NotificationService.instance.showCallNotification(
                  callerName: 'Test Caller',
                  callerId: '123',
                );
              },
              child: const Text('Test Call Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final callsService = CallsService();
                await callsService.startGroupCall();
              },
              child: const Text('Start Video Call'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: NotificationService.instance.getDeviceToken(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText('FCM Token: ${snapshot.data}'),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
} 