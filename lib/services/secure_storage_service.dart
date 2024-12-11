import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _keyKey = 'encryption_key';
  static const String _ivKey = 'encryption_iv';

  factory SecureStorageService() {
    return instance;
  }

  SecureStorageService._internal();

  Future<void> generateAndStoreNewKey() async {
    // Generate a random UUID and hash it for the key
    final uuid = const Uuid().v4();
    final keyBytes = sha256.convert(utf8.encode(uuid)).bytes;
    final key = base64.encode(keyBytes);
    
    // Generate random IV
    final ivBytes = List<int>.generate(16, (i) => DateTime.now().millisecondsSinceEpoch % 256);
    final iv = base64.encode(ivBytes);

    // Store securely
    await _storage.write(key: _keyKey, value: key);
    await _storage.write(key: _ivKey, value: iv);
    
    print('🔐 New encryption key and IV generated and stored');
  }

  Future<Map<String, String>> getEncryptionKeys() async {
    final key = await _storage.read(key: _keyKey);
    final iv = await _storage.read(key: _ivKey);
    
    if (key == null || iv == null) {
      print('🔑 No encryption keys found, generating new ones');
      await generateAndStoreNewKey();
      return getEncryptionKeys();
    }
    
    return {
      'key': key,
      'iv': iv,
    };
  }
} 