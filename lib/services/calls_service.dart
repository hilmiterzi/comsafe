import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'encryption_service.dart';

class CallsService {
  static final CallsService _instance = CallsService._internal();
  late final DatabaseReference _database;
  static const String CHANNEL_NAME = 'comsafe_channel_1';

  factory CallsService() {
    return _instance;
  }

  CallsService._internal() {
    print('🔥 Setting Database URL');
    FirebaseDatabase.instance.databaseURL = 'https://generation-671ae-default-rtdb.europe-west1.firebasedatabase.app';
    _database = FirebaseDatabase.instance.ref();
    print('✅ Database initialized with URL: ${FirebaseDatabase.instance.databaseURL}');
  }

  Future<void> startGroupCall() async {
    print('📞 Starting group call');
    final deviceId = await _deviceId;
    
    try {
      // Clean up old calls first
      final snapshot = await _database.child('calls').get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        print('🧹 Cleaning up old calls');
        await _database.child('calls').child(CHANNEL_NAME).update({
          'status': _encryptValue('ended')
        });
      }

      // Encrypt call data
      final encryptedData = {
        'channelName': _encryptValue(CHANNEL_NAME),
        'initiator': _encryptValue(deviceId),
        'status': _encryptValue('active'),
        'timestamp': ServerValue.timestamp,
      };

      print('🔐 Setting encrypted call data');
      await _database.child('calls').child(CHANNEL_NAME).set(encryptedData);
      print('✅ Call started with encrypted data');
    } catch (e) {
      print('❌ Error starting call: $e');
    }
  }

  Stream<Map<String, dynamic>> listenForCalls() {
    print('👂 Starting to listen for calls');
    final controller = StreamController<Map<String, dynamic>>();
    
    _database.child('calls').child(CHANNEL_NAME).onValue.listen((event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final deviceId = await _deviceId;

        // Decrypt the data
        final decryptedData = {
          'channelName': _decryptValue(data['channelName'] as String),
          'initiator': _decryptValue(data['initiator'] as String),
          'status': _decryptValue(data['status'] as String),
          'timestamp': data['timestamp'],
        };

        if (decryptedData['status'] == 'active') {
          final participants = data['participants'] as Map<dynamic, dynamic>? ?? {};
          
          if (decryptedData['initiator'] != deviceId && !participants.containsKey(deviceId)) {
            controller.add({CHANNEL_NAME: decryptedData});
            print('📱 Active call available for joining');
          } else {
            controller.add({});
            print('📱 Already in call or initiated call');
          }
        } else {
          controller.add({});
          print('📭 No active calls for this device');
        }
      }
    });
    
    return controller.stream;
  }

  String _encryptValue(String value) {
    final bytes = utf8.encode(value);
    final encrypted = EncryptionService.instance.encryptData(Uint8List.fromList(bytes));
    return base64.encode(encrypted);
  }

  String _decryptValue(String encryptedValue) {
    final bytes = base64.decode(encryptedValue);
    final decrypted = EncryptionService.instance.decryptData(Uint8List.fromList(bytes));
    return utf8.decode(decrypted);
  }

  Future<String> get _deviceId async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📱 Device Token: $token');
    return token ?? 'unknown';
  }

  Future<void> joinCall(String callId) async {
    print('👋 Joining call: $callId');
    final deviceId = await _deviceId;
    
    try {
      // Add participant to the call with encrypted data
      final encryptedParticipant = {
        'deviceId': _encryptValue(deviceId),
        'status': _encryptValue('active'),
        'joinedAt': ServerValue.timestamp,
      };

      await _database
          .child('calls')
          .child(callId)
          .child('participants')
          .child(deviceId)
          .set(encryptedParticipant);
      
      print('✅ Successfully joined call');
    } catch (e) {
      print('❌ Error joining call: $e');
      throw Exception('Failed to join call: $e');
    }
  }

  Future<void> declineCall(String callId) async {
    print('❌ Declining call: $callId');
    final deviceId = await _deviceId;
    
    try {
      // Add declined status with encryption
      final encryptedDecline = {
        'deviceId': _encryptValue(deviceId),
        'status': _encryptValue('declined'),
        'timestamp': ServerValue.timestamp,
      };

      await _database
          .child('calls')
          .child(callId)
          .child('declined')
          .child(deviceId)
          .set(encryptedDecline);
      
      print('✅ Successfully declined call');
    } catch (e) {
      print('❌ Error declining call: $e');
      throw Exception('Failed to decline call: $e');
    }
  }

  Future<void> endCall(String callId) async {
    print('🔚 Ending call: $callId');
    try {
      await _database.child('calls').child(callId).update({
        'status': _encryptValue('ended'),
        'endedAt': ServerValue.timestamp,
      });
      print('✅ Call ended');
    } catch (e) {
      print('❌ Error ending call: $e');
      throw Exception('Failed to end call: $e');
    }
  }
} 