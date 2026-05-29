import 'package:fashion_app/tools/upload_products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/design_system/theme_bootstrapper.dart';
import 'core/design_system/theme_provider.dart';
import 'core/design_system/theme_mapper.dart';
import 'features/splash/flower_splash_screen.dart';
import 'features/tenant/tenant_provider.dart';
import 'features/tenant/tenant_setup_screen.dart';
import 'features/brands/brand_screen.dart';
import 'firebase_options.dart';

import 'core/services/fcm_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🚀 APP STARTING...");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ FIREBASE INITIALIZED");
  } catch (e) {
    print("❌ FIREBASE INIT ERROR: $e");
  }

  // 🔥 ABILITA PERSISTENZA OFFLINE PER I DATI
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print("✅ FIRESTORE SETTINGS APPLIED");
  } catch (e) {
    print("⚠️ FIRESTORE SETTINGS ERROR: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.instance.requestPermission();

  // 🔥 1. PRENDI IL TOKEN ALL'AVVIO
  FirebaseMessaging.instance.getToken().then((token) {
    print("🔥 FCM TOKEN: $token");
    FcmService.syncToken(token);
  }).catchError((e) {
    print("❌ FCM TOKEN ERROR: $e");
  });

  // 🔥 2. ASCOLTA SE IL TOKEN CAMBIA (Refresh)
  FirebaseMessaging.instance.onTokenRefresh.listen((token) => FcmService.syncToken(token));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 NOTIFICA IN ARRIVO: ${message.notification?.title}");
  });

  print("🏁 RUNNING APP");
  runApp(
    const ProviderScope(
      child: ThemeBootstrapper(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Gestione link a freddo (app chiusa)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    // Gestione link a caldo (app in background)
    _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    print("🔗 DEEP LINK RICEVUTO: $uri");
    // Esempio URL: showroomflow://config?tenantId=MORONI
    final tenantId = uri.queryParameters['tenantId'];
    if (tenantId != null && tenantId.isNotEmpty) {
      ref.read(tenantProvider.notifier).setTenant(tenantId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = ref.watch(appThemeProvider);
    final tenantState = ref.watch(tenantProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion App',
      theme: ThemeMapper.toThemeData(themeModel),
      home: tenantState == null
          ? const TenantSetupScreen()
          : const FlowerSplashScreen(), // Lo splash porta poi alla BrandScreen
    );
  }
}
