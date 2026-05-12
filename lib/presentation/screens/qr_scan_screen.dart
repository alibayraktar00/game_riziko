import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanning = true;
  String? _scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR KODU TARA',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.neonGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Scanner Section
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      AppTheme.neonShadow,
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MobileScanner(
                      onDetect: _onBarcodeDetect,
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                        torchEnabled: false,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Status Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_scannedCode != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF88), Color(0xFF00D084)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            AppTheme.neonShadow,
                            BoxShadow(
                              color: const Color(0xFF00FF88).withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'QR KODU OKUNDU!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kod: $_scannedCode',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _proceedToNickname(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00FF88),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'DEVAM ET',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 48,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'QR kodu kameraya gösterin',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    
    if (code != null && _isValidRizikoCode(code)) {
      setState(() {
        isScanning = false;
        _scannedCode = _extractCodeFromUrl(code);
      });
    }
  }

  bool _isValidRizikoCode(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'riziko' && 
             uri.path == '/join' && 
             uri.queryParameters.containsKey('code');
    } catch (e) {
      return false;
    }
  }

  String _extractCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['code'] ?? '';
    } catch (e) {
      return '';
    }
  }

  void _proceedToNickname() {
    if (_scannedCode != null) {
      context.go('/nickname?code=$_scannedCode');
    }
  }
}
