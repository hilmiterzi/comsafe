import 'dart:async';
import 'package:flutter/material.dart';
import '../services/calls_service.dart';
import '../screens/video_call_screen.dart';
import '../screens/incoming_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CallsService _callsService = CallsService();
  StreamSubscription? _callSubscription;

  @override
  void initState() {
    super.initState();
    _listenForCalls();
  }

  void _listenForCalls() {
    _callSubscription = _callsService.listenForCalls().listen((callData) {
      if (!mounted) return;
      if (callData.isNotEmpty && callData['status'] == 'active') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(
              callerName: 'Group Call',
              onAccept: () => _joinCall(callData['callId']),
              onDecline: () {
                Navigator.pop(context);
                _callsService.declineCall(callData['callId']);
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _startCall() async {
    await _callsService.startGroupCall();
  }

  Future<void> _joinCall(String callId) async {
    if (!mounted) return;
    await _callsService.joinCall(callId);
    if (!mounted) return;
    
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(channelName: callId),
      ),
    );
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Call App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startCall,
              icon: Icon(Icons.call),
              label: Text('Start Group Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 