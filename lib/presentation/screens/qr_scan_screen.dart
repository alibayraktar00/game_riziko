import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/riziko_scaffold.dart';

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
    
    return RizikoScaffold(
      title: 'QR KODU TARA',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/mode-selection'),
      ),
      body: Column(
            children: [
              // Scanner Section
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                child: _scannedCode != null
                    ? GlassCard(
                        accentColor: const Color(0xFF00FF87),
                        selected: true,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
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
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'QR KODU OKUNDU!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF00FF87)),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Kod: $_scannedCode',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppSpacing.md + 4),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => _proceedToNickname(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FF87),
                                  foregroundColor: const Color(0xFF070913),
                                ),
                                child: const Text('DEVAM ET'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GlassCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'QR Kodu Kameraya Gösterin',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
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
