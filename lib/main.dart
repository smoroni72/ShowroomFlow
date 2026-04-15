import 'package:fashion_app/tools/upload_products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fashion_app/features/splash/splash_screen.dart';
import 'core/design_system/theme_bootstrapper.dart';
import 'features/brands/brand_screen.dart';
import 'features/splash/flower_splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.setAutoInitEnabled(true);

// 🔥 NON BLOCCANTE
  FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.instance.getToken().then((token) {
    print("🔥 FCM TOKEN: $token");
  }).catchError((e) {
    print("❌ FCM TOKEN ERROR: $e");
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 NOTIFICA IN ARRIVO: ${message.notification?.title}");
  });

  //da togliere dopo
  // await uploadProducts();
  // runApp(MyApp());
  // await FirebaseAuth.instance.signOut();

  runApp(
      const ProviderScope(
        child: ThemeBootstrapper(
          child: MyApp(),
        ),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion App',
      theme: ThemeData(
        useMaterial3: true,
      ),
       home: const FlowerSplashScreen(),
    );
  }
}

