import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../services/qr_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanning = true;
  final QRService _qrService = QRService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tara'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera Section
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
            // Status Section - Fixed height to prevent overflow
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 120,
                maxHeight: MediaQuery.of(context).size.height * 0.25,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isScanning) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text(
                      'QR kodu kameraya gösterin',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QR kod okundu!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isScanning = true;
                          });
                        },
                        child: const Text('Tekrar Tara'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    
    if (code != null && _qrService.isValidSessionUrl(code)) {
      setState(() {
        isScanning = false;
      });
      
      final sessionId = _qrService.extractSessionIdFromUrl(code);
      if (mounted) {
        context.go('/multiplayer/join/$sessionId');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
