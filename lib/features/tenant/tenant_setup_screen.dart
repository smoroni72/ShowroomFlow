import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../splash/flower_splash_screen.dart';
import 'tenant_provider.dart';

class TenantSetupScreen extends ConsumerStatefulWidget {
  const TenantSetupScreen({super.key});

  @override
  ConsumerState<TenantSetupScreen> createState() => _TenantSetupScreenState();
}

class _TenantSetupScreenState extends ConsumerState<TenantSetupScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _isScanning = false;

  Future<void> _verifyAndSetTenant(String rawId) async {
    if (rawId.isEmpty) return;

    String tenantId = rawId;
    // Se è un deep link o URL, estraiamo l'ID
    if (rawId.contains('tenantId=')) {
      tenantId = rawId.split('tenantId=').last.split('&').first;
    } else if (rawId.contains('://')) {
      // Se è un URL generico, proviamo a prendere l'ultima parte
      tenantId = rawId.split('/').last;
    }

    tenantId = tenantId.trim();
    if (tenantId.isEmpty) return;

    setState(() => _loading = true);

    try {
      // Verifichiamo se il tenant esiste in Firestore
      final doc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .get();

      if (doc.exists) {
        await ref.read(tenantProvider.notifier).setTenant(tenantId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Azienda '${doc.data()?['name'] ?? tenantId}' configurata!")),
          );

          // Navighiamo allo splash screen che caricherà i dati del nuovo tenant
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FlowerSplashScreen()),
                (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Codice azienda non valido.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante la configurazione: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sfondo elegante (gradiente o immagine)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    "Configurazione Iniziale",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Inquadra il QR Code sul kit di prospezione o inserisci il codice manualmente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),

                  // Inserimento Manuale
                  TextField(
                    controller: _codeController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Codice Azienda (es. MORONI)",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _loading
                          ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () => _verifyAndSetTenant(_codeController.text.trim()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("OPPURE", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 24),

                  // Bottone Scanner
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isScanning = true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("SCANSIONA QR CODE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Layer Scanner (appare quando cliccato)
          if (_isScanning)
            Positioned.fill(
              child: Stack(
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final rawValue = barcode.rawValue;
                        if (rawValue != null) {
                          setState(() => _isScanning = false);
                          _verifyAndSetTenant(rawValue);
                          break;
                        }
                      }
                    },
                  ),
                  // Overlay Scanner UI
                  Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: Colors.white,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 250,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => setState(() => _isScanning = false),
                    ),
                  ),
                  const Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Text(
                      "Inquadra il QR Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Helper per l'overlay dello scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: rect.center, width: cutOutSize, height: cutOutSize),
          Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxRect = Rect.fromCenter(
        center: rect.center, width: cutOutSize, height: cutOutSize);

    canvas.drawPath(
        Path.combine(
            PathOperation.difference,
            Path()..addRect(rect),
            Path()
              ..addRRect(RRect.fromRectAndRadius(
                  boxRect, Radius.circular(borderRadius)))),
        backgroundPaint);

    // Disegna gli angoli
    final path = Path()
      ..moveTo(boxRect.left, boxRect.top + borderLength)
      ..lineTo(boxRect.left, boxRect.top)
      ..lineTo(boxRect.left + borderLength, boxRect.top)
      ..moveTo(boxRect.right - borderLength, boxRect.top)
      ..lineTo(boxRect.right, boxRect.top)
      ..lineTo(boxRect.right, boxRect.top + borderLength)
      ..moveTo(boxRect.right, boxRect.bottom - borderLength)
      ..lineTo(boxRect.right, boxRect.bottom)
      ..lineTo(boxRect.right - borderLength, boxRect.bottom)
      ..moveTo(boxRect.left + borderLength, boxRect.bottom)
      ..lineTo(boxRect.left, boxRect.bottom)
      ..lineTo(boxRect.left, boxRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
