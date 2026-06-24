import 'dart:ui';
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'QR KODU TARA',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/mode-selection'),
        ),
        backgroundColor: Colors.transparent,
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
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    if (_scannedCode != null) ...[
                      // Scanned Success Glassmorphic Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF00FF87).withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00FF87),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    size: 36,
                                    color: Color(0xFF070913),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'QR KODU OKUNDU!',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00FF87),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kod: $_scannedCode',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => _proceedToNickname(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00FF87),
                                      foregroundColor: const Color(0xFF070913),
                                      elevation: 8,
                                      shadowColor: const Color(0xFF00FF87).withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      'DEVAM ET',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Waiting for Scan Glassmorphic Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 40,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'QR Kodu Kameraya Gösterin',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
             (uri.host == 'game' || uri.path == '/game') && 
             uri.queryParameters.containsKey('code');
    } catch (e) {
      // If not a URL, check if it's a 4-character alphanumeric code
      return url.length == 4 && RegExp(r'^[A-Z0-9]+$').hasMatch(url);
    }
  }

  String _extractCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'riziko') {
        return uri.queryParameters['code'] ?? '';
      }
      return url; // Fallback to raw code
    } catch (e) {
      return url;
    }
  }

  void _proceedToNickname() {
    if (_scannedCode != null) {
      context.go('/nickname?code=$_scannedCode');
    }
  }
}
