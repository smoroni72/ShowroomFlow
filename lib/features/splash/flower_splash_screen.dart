import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/showroom_provider.dart';
import '../brands/brand_screen.dart';

class FlowerSplashScreen extends ConsumerStatefulWidget {
  const FlowerSplashScreen({super.key});

  @override
  ConsumerState<FlowerSplashScreen> createState() =>
      _FlowerSplashScreenState();
}

class _FlowerSplashScreenState extends ConsumerState<FlowerSplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _growthController;
  late AnimationController _windController;

  @override
  void initState() {
    super.initState();

    _growthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    /// navigazione
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BrandScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _growthController.dispose();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showroom = ref.watch(showroomProvider).value;

    final name = showroom?['name'] ?? "Francesca Spadini";
    final subtitle = showroom?['subtitle'] ?? "Rappresentanze";
    final city = showroom?['city'] ?? "Genzano Di Roma";
    final address = showroom?['address'] ?? "Via Achille Grandi, 48";
    final postcode = showroom?['postcode'] ?? "00045";
    final phone = showroom?['phone'] ?? "340 4100953";
    final email = showroom?['email'] ?? "francescaspadini@virgilio.it";


    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// SFONDO
          Container(color: Colors.white),

          /// LOGO CENTRALE
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("---",
                    style: TextStyle(color: Colors.grey, letterSpacing: 8)),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  color: const Color(0xFFBC4A8C),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFFBC4A8C),
                    fontSize: 16,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          /// 🌸 FIORI (UGUALE AL TUO)
          AnimatedBuilder(
            animation: Listenable.merge(
                [_growthController, _windController]),
            builder: (context, child) {
              return Stack(
                children: [
                  _buildGrowingFlower(size, x: 0.08, color: Colors.yellow.shade600, delay: 0.0, flowerType: 0, maxHeight: 0.42, sizeMult: 0.8),
                  _buildGrowingFlower(size, x: 0.18, color: Colors.purpleAccent, delay: 0.2, flowerType: 1, maxHeight: 0.38, sizeMult: 1.1),
                  _buildGrowingFlower(size, x: 0.28, color: Colors.pinkAccent, delay: 0.5, flowerType: 3, maxHeight: 0.46, sizeMult: 1.3),
                  _buildGrowingFlower(size, x: 0.40, color: const Color(0xFFBC4A8C), delay: 0.1, flowerType: 2, maxHeight: 0.40, sizeMult: 0.9),
                  _buildGrowingFlower(size, x: 0.55, color: Colors.deepPurple, delay: 0.3, flowerType: 4, maxHeight: 0.48, sizeMult: 1.2),
                  _buildGrowingFlower(size, x: 0.68, color: Colors.indigoAccent, delay: 0.6, flowerType: 1, maxHeight: 0.35, sizeMult: 0.7),
                  _buildGrowingFlower(size, x: 0.80, color: Colors.orangeAccent, delay: 0.4, flowerType: 3, maxHeight: 0.44, sizeMult: 1.0),
                  _buildGrowingFlower(size, x: 0.92, color: Colors.pink.shade300, delay: 0.2, flowerType: 0, maxHeight: 0.41, sizeMult: 0.8),
                ],
              );
            },
          ),

          /// 📞 TELEFONO
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBC4A8C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          /// 📍 INDIRIZZO + EMAIL (NUOVO)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      postcode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGrowingFlower(
      Size screen, {
        required double x,
        required Color color,
        required double delay,
        required int flowerType,
        required double maxHeight,
        required double sizeMult,
      }) {
    final double growthProgress = Curves.easeInOutQuart.transform(
      math.max(0, math.min(1, (_growthController.value - delay) / (1 - delay))),
    );

    final double currentFlowerHeight =
        screen.height * maxHeight * growthProgress;
    final double windAngle =
        math.sin(_windController.value * math.pi * 2) * 0.05;

    return Positioned(
      left: screen.width * x - 30,
      bottom: 0,
      child: CustomPaint(
        size: Size(60, currentFlowerHeight + 50),
        painter: GrowingFlowerPainter(
          color: color,
          type: flowerType,
          growth: growthProgress,
          windAngle: windAngle,
          sizeMult: sizeMult,
        ),
      ),
    );
  }
}




class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: const Center(child: Text("Benvenuto!")),
    );
  }
}

class GrowingFlowerPainter extends CustomPainter {
  final Color color;
  final int type;
  final double growth;
  final double windAngle;
  final double sizeMult;

  GrowingFlowerPainter({
    required this.color,
    required this.type,
    required this.growth,
    required this.windAngle,
    required this.sizeMult,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (growth <= 0) return;

    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double startX = size.width / 2;
    final double startY = size.height;
    final double endX = startX + (windAngle * size.height * 0.4);
    final double endY = 50.0;

    var path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(
      startX + (windAngle * size.height * 0.15),
      startY - (size.height / 2),
      endX,
      endY,
    );
    canvas.drawPath(path, paint);

    // Foglie casuali
    if (growth > 0.45)
      _drawLeaf(canvas, Offset(startX, startY - size.height * 0.35), true);
    if (growth > 0.75)
      _drawLeaf(canvas, Offset(startX, startY - size.height * 0.65), false);

    if (growth > 0.2) {
      final petalPaint = Paint()
        ..color = color.withOpacity(math.min(1, growth * 2))
        ..style = PaintingStyle.fill;

      final center = Offset(endX, endY);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(windAngle);

      _drawFlowerHead(canvas, petalPaint);
      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, Offset pos, bool left) {
    final leafPaint = Paint()
      ..color = Colors.green.shade400
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(left ? -0.6 : 0.6);
    canvas.drawOval(Rect.fromLTWH(0, 0, left ? -18 : 18, 10), leafPaint);
    canvas.restore();
  }

  void _drawFlowerHead(Canvas canvas, Paint petalPaint) {
    final double scale = math.min(1.0, growth * 1.3) * sizeMult;

    switch (type) {
      case 0: // Margherita sfrangiata
        for (int i = 0; i < 12; i++) {
          canvas.save();
          canvas.rotate(i * math.pi / 6);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(0, -12 * scale),
              width: 4 * scale,
              height: 24 * scale,
            ),
            petalPaint,
          );
          canvas.restore();
        }
        canvas.drawCircle(
          Offset.zero,
          6 * scale,
          Paint()..color = Colors.yellow.shade800,
        );
        break;

      case 1: // Fiore tondo (tipo Ortensia/Palla)
        for (int i = 0; i < 6; i++) {
          canvas.save();
          canvas.rotate(i * math.pi / 3);
          canvas.drawCircle(Offset(0, -10 * scale), 12 * scale, petalPaint);
          canvas.restore();
        }
        canvas.drawCircle(
          Offset.zero,
          8 * scale,
          Paint()..color = Colors.white.withOpacity(0.3),
        );
        break;

      case 2: // Tulipano / Bocciolo chiuso
        var path = Path();
        path.moveTo(-15 * scale, 0);
        path.quadraticBezierTo(-18 * scale, -30 * scale, 0, -40 * scale);
        path.quadraticBezierTo(18 * scale, -30 * scale, 15 * scale, 0);
        path.close();
        canvas.drawPath(path, petalPaint);
        break;

      case 3: // Fiore a petali larghi (tipo Ibisco)
        for (int i = 0; i < 5; i++) {
          canvas.save();
          canvas.rotate(i * 2 * math.pi / 5);
          var p = Path();
          p.moveTo(0, 0);
          p.quadraticBezierTo(-20 * scale, -25 * scale, 0, -35 * scale);
          p.quadraticBezierTo(20 * scale, -25 * scale, 0, 0);
          canvas.drawPath(p, petalPaint);
          canvas.restore();
        }
        canvas.drawCircle(
          Offset.zero,
          4 * scale,
          Paint()..color = Colors.black26,
        );
        break;

      case 4: // Garofano / Molti petali sovrapposti
        for (int i = 0; i < 16; i++) {
          canvas.save();
          canvas.rotate(i * math.pi / 8);
          // CORREZIONE: Usiamo withOpacity sul colore invece del setter inesistente .opacity
          final layeredPetalPaint = Paint()
            ..color = color.withOpacity(0.6 * math.min(1, growth * 2))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(0, -12 * scale),
            8 * scale,
            layeredPetalPaint,
          );
          canvas.restore();
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant GrowingFlowerPainter oldDelegate) =>
      oldDelegate.growth != growth || oldDelegate.windAngle != windAngle;
}
