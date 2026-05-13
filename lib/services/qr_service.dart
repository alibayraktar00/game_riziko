class QRService {
  static const String _scheme = 'riziko';
  static const String _host = 'game';
  
  String generateGameSessionUrl(String sessionId) {
    return '$_scheme://$_host?code=$sessionId';
  }
  
  String extractSessionIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == _scheme) {
        return uri.queryParameters['code'] ?? url;
      }
      return url;
    } catch (e) {
      return url;
    }
  }
  
  Future<String> generateQRCodeData(String sessionId) async {
    return generateGameSessionUrl(sessionId);
  }
  
  String generateNewSessionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 4; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }
  
  bool isValidSessionUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == _scheme && uri.queryParameters.containsKey('code');
    } catch (e) {
      return url.length == 4 && RegExp(r'^[A-Z0-9]+$').hasMatch(url);
    }
  }
}
