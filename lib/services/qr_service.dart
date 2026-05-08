import 'package:uuid/uuid.dart';

class QRService {
  static const String _baseUrl = 'riziko://game/';
  
  String generateGameSessionUrl(String sessionId) {
    return '$_baseUrl$sessionId';
  }
  
  String extractSessionIdFromUrl(String url) {
    if (url.startsWith(_baseUrl)) {
      return url.substring(_baseUrl.length);
    }
    
    // Handle different URL formats
    if (url.contains('sessionId=')) {
      final uri = Uri.parse(url);
      return uri.queryParameters['sessionId'] ?? '';
    }
    
    // If it's just the session ID
    return url;
  }
  
  Future<String> generateQRCodeData(String sessionId) async {
    final url = generateGameSessionUrl(sessionId);
    return url;
  }
  
  String generateNewSessionId() {
    final uuid = Uuid();
    return uuid.v4().substring(0, 8); // Short ID for QR codes
  }
  
  bool isValidSessionUrl(String url) {
    return url.startsWith(_baseUrl) || url.contains('sessionId=');
  }
}
