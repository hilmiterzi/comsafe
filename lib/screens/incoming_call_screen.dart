import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevents back button
      child: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                callerName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: onDecline,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    onPressed: onAccept,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.call),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 