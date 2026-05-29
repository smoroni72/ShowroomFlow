import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/theme_provider.dart';
import '../../core/providers/showroom_provider.dart';
import '../brands/brand_screen.dart';
import '../tenant/tenant_provider.dart';

class FlowerSplashScreen extends ConsumerStatefulWidget {
  const FlowerSplashScreen({super.key});

  @override
  ConsumerState<FlowerSplashScreen> createState() =>
      _FlowerSplashScreenState();
}

class _FlowerSplashScreenState extends ConsumerState<FlowerSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleIn = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();

    // Auto login per demo-tenant in background
    _checkAndAutoLoginDemo();

    /// Navigazione sicura dopo 4 secondi
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        print("🚀 [SPLASH] Navigazione a BrandScreen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BrandScreen()),
        );
      }
    });
  }

  Future<void> _checkAndAutoLoginDemo() async {
    try {
      final tenantId = ref.read(tenantProvider);
      if (tenantId == "demo-tenant") {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null || currentUser.email != "demo@showroomflow.com") {
          print("🔑 [DEMO-AUTO-LOGIN] Rilevato demo-tenant. Avvio caricamento licenza demo...");
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "demo@showroomflow.com",
            password: "password-demo",
          );
          print("🔑 [DEMO-AUTO-LOGIN] Autenticazione automatica demo completata!");
        }
      }
    } catch (e) {
      print("⚠️ [DEMO-AUTO-LOGIN] Errore nell'autologin demo: $e");
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showroom = ref.watch(showroomProvider).value;
    final themeModel = ref.watch(appThemeProvider);
    final splashImageUrl = themeModel.splashImageUrl;

    // Default high-fashion photo if no custom config image is selected
    const defaultSplashUrl = "https://res.cloudinary.com/dvcg9eu38/image/upload/v1779702986/ChatGPT_Image_25_mag_2026_11_54_54_mndtik.png";
    final activeSplashUrl = (splashImageUrl != null && splashImageUrl.isNotEmpty)
        ? splashImageUrl
        : defaultSplashUrl;

    final bool isNetworkImage = activeSplashUrl.startsWith('http://') || activeSplashUrl.startsWith('https://');

    // Dati dello showroom dinamici o placeholder generici raffinati
    final name = showroom?['name'] ?? "Demo Tenant";
    final subtitle = showroom?['subtitle'] ?? "rappresentanze";
    final city = showroom?['city'] ?? "Roma";
    final address = showroom?['address'] ?? "via Roma";
    final postcode = showroom?['postcode'] ?? "00100";
    final phone = showroom?['phone'] ?? "+39 06 xx xx xxx";
    final email = showroom?['email'] ?? "demo@showroomflow.it";

    return Scaffold(
      backgroundColor: themeModel.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Sfondo di fallback gradiente
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeModel.background,
                      themeModel.background.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Sfondo personalizzabile a schermo intero con supporto automatico sia per URL Web che per Asset locali
            Positioned.fill(
              child: isNetworkImage
                  ? Image.network(
                activeSplashUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("⚠️ [SPLASH] Fallito caricamento immagine di rete, provo con asset locale: $error");
                  return Image.asset(
                    'assets/images/splash.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                },
              )
                  : Image.asset(
                activeSplashUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("⚠️ [SPLASH] Fallito caricamento asset '$activeSplashUrl': $error");
                  // Prova un fallback alternativo comune
                  return Image.asset(
                    'assets/images/splash.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            // Overlay di oscuramento ad alto contrasto per rendere leggibili i testi chiari
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.68),
              ),
            ),

            // Contenuto animato a schermo intero
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.scale(
                      scale: _scaleIn.value,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Sezione Superiore (Azienda / Tagline d'ingresso)
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.door_sliding_outlined,
                                        color: themeModel.primary.withOpacity(0.8),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "BENVENUTO",
                                        style: TextStyle(
                                          color: themeModel.textSecondary.withOpacity(0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 4.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Sezione Centrale (Nome Showroom principale + Sottotitolo)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: themeModel.primary.withOpacity(0.3), width: 1),
                                          bottom: BorderSide(color: themeModel.primary.withOpacity(0.3), width: 1),
                                        ),
                                      ),
                                      child: Text(
                                        name.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 5.0,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      subtitle.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeModel.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 3.0,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          themeModel.primary.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Sezione Inferiore (Contatti / Indirizzo Showroom)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Numero di telefono in un box delicato
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: themeModel.primary.withOpacity(0.12),
                                          border: Border.all(
                                            color: themeModel.primary.withOpacity(0.3),
                                            width: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          phone,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Indirizzo
                                      Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.45),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$postcode · $city".toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(0.45),
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Email di contatto
                                      Text(
                                        email.toLowerCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: themeModel.primary.withOpacity(0.7),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
