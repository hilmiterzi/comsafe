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
    print('🏠 HomeScreen initialized');
    _listenForCalls();
  }

  void _listenForCalls() {
    print('👂 Starting to listen for calls in HomeScreen');
    _callSubscription = _callsService.listenForCalls().listen(
      (callData) {
        print('📞 Received call data in HomeScreen: $callData');
        if (callData.isNotEmpty) {
          print('📱 Found active call, showing incoming screen');
          final String callId = callData.entries.first.key;
          
          if (mounted) {
            print('🔔 Showing incoming call screen for call: $callId');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncomingCallScreen(
                  callerName: 'Group Call',
                  onAccept: () async {
                    print('✅ Call accepted: $callId');
                    await _joinCall(callId);
                  },
                  onDecline: () async {
                    print('❌ Call declined: $callId');
                    await _callsService.declineCall(callId);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
            );
          }
        }
      },
      onError: (error) {
        print('❌ Error in call listener: $error');
      },
    );
  }

  Future<void> _startCall() async {
    print('📞 Starting new call');
    try {
      await _callsService.startGroupCall();
      
      if (!mounted) return;
      print('🎥 Navigating initiator to video call screen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            channelName: CallsService.CHANNEL_NAME,
            isInitiator: true,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error starting call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start call: $e')),
        );
      }
    }
  }

  Future<void> _joinCall(String callId) async {
    print('👋 Joining call: $callId');
    try {
      await _callsService.joinCall(callId);
      
      if (!mounted) return;
      print('🎥 Navigating joiner to video call screen');
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            channelName: CallsService.CHANNEL_NAME,
            isInitiator: false,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error joining call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join call: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    print('🏠 Disposing HomeScreen');
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