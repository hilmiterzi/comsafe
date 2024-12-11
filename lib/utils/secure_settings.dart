import 'dart:convert';

class SecureSettings {
  static final List<int> _key = [
    // Obfuscated Agora App ID bytes
    0x38, 0x61, 0x38, 0x30, 0x37, 0x32, 0x38, 0x33,
    0x30, 0x39, 0x38, 0x38, 0x34, 0x62, 0x36, 0x64,
    0x62, 0x65, 0x37, 0x33, 0x30, 0x38, 0x32, 0x37,
    0x32, 0x66, 0x36, 0x31, 0x61, 0x62, 0x30, 0x36
  ];

  static String get agoraAppId {
    return utf8.decode(_key);
  }

  static String generateToken(String channelName) {
    // In production, this should call your token server
    // For now, returning a temporary token
    return "007eJxTYCjk7quVnpI5cdp1BoPnt/Jtz6TafVp4e3o7g8PE49N+X/ZWYLBItDAwN7IwNrC0sDBJMktJSjU3NrAwMjdKMzNMTDIwy34Rmd4QyMhQyy3MwsgAgSC+IENyfm5xYlpqfHJGYl5eak68IQMDAAkqI9Y=";
  }
} 