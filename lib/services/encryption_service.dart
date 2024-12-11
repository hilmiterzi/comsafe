import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final EncryptionService instance = EncryptionService._internal();
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  // These bytes will be obfuscated in the binary
  static final List<int> _keyBytes = [
    0x41, 0x72, 0x65, 0x20, 0x79, 0x6F, 0x75, 0x20,
    0x74, 0x72, 0x79, 0x69, 0x6E, 0x67, 0x20, 0x74,
    0x6F, 0x20, 0x72, 0x65, 0x61, 0x64, 0x20, 0x74,
    0x68, 0x69, 0x73, 0x3F, 0x20, 0x3A, 0x29, 0x20
  ];

  static final List<int> _ivBytes = [
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x74, 0x68,
    0x65, 0x72, 0x65, 0x21, 0x20, 0x3A, 0x44, 0x20
  ];

  factory EncryptionService() {
    return instance;
  }

  EncryptionService._internal() {
    final key = encrypt.Key(Uint8List.fromList(_keyBytes));
    _iv = encrypt.IV(Uint8List.fromList(_ivBytes));
    _encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    print('🔐 Encryption service initialized');
  }

  Map<String, String> getAgoraEncryptionConfig() {
    return {
      'encryptionMode': 'AES_256_CBC',
      'encryptionKey': String.fromCharCodes(_keyBytes),
    };
  }

  Uint8List encryptData(Uint8List data) {
    final encrypted = _encrypter.encryptBytes(data.toList(), iv: _iv);
    return Uint8List.fromList(encrypted.bytes);
  }

  Uint8List decryptData(Uint8List encryptedData) {
    final encrypted = encrypt.Encrypted(encryptedData);
    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: _iv));
  }
} 