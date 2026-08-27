import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

class IsbnScanPage extends StatefulWidget {
  const IsbnScanPage({super.key});

  @override
  State<IsbnScanPage> createState() => _IsbnScanPageState();
}

class _IsbnScanPageState extends State<IsbnScanPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Scan barcode'),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
              tooltip: 'Toggle flash',
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            // Viewfinder overlay
            Center(
              child: Container(
                width: 260,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 2),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
              ),
            ),
            // Bottom hint
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Point at the barcode on the back of the book',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: Spacing.lg),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Enter details manually'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null) return;

    // Accept ISBN-13 (starts with 978/979) or EAN-13
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return;

    _scanned = true;
    Navigator.of(context).pop(digits); // returns ISBN to AddBookPage
  }
}
