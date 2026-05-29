import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile/screens/profile_screen.dart';
import '../tenant/tenant_provider.dart';
import 'auth_service.dart';
import '../../core/services/fcm_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isRegister = false;
  bool loading = false;
  bool _obscurePassword = true;

  final AuthService _auth = AuthService();

  Future<void> submit() async {

    /// CONTROLLO PASSWORD UGUALI
    if (isRegister &&
        _passwordController.text != _confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le password non coincidono"),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      if (isRegister) {

        await _auth.signUpEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          shopName: _shopController.text.trim(),
        );

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Registrazione completata"),
            content: const Text(
                "Ti abbiamo inviato un'email di verifica. "
                    "Controlla la tua casella di posta e clicca sul link per attivare l'account prima di accedere."
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    isRegister = false; // Switch to login
                  });
                },
                child: const Text("OK, ACCEDI"),
              ),
            ],
          ),
        );

        return;

      } else {

        final cred = await _auth.loginEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = cred.user!;

        // 1. Controllo Verifica Email
        if (!user.emailVerified && user.email != "demo@showroomflow.com") {
          await _auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Devi prima verificare la tua email. Controlla la tua casella di posta.")),
            );
          }
          return;
        }

        // 2. Controllo Account Attivo e Tenant
        // Cerca in:
        // 1. users_admin (root) - SuperAdmin
        // 2. tenants/{azienda}/users_admin - Admin Web
        // 3. tenants/{azienda}/users - Utenti Mobile

        var userDoc = await FirebaseFirestore.instance.collection("users_admin").doc(user.uid).get();
        bool isGlobalAdmin = userDoc.exists;
        String? detectedTenantId;

        if (!userDoc.exists && user.email == "s.moroni72@gmail.com") {
          print("🚨 [LOGIN] Auto-creazione profilo ADMIN in users_admin: ${user.email}");
          await FirebaseFirestore.instance.collection("users_admin").doc(user.uid).set({
            "uid": user.uid,
            "email": user.email,
            "displayName": user.displayName ?? "Admin",
            "active": true,
            "tenantId": "azienda_master",
            "role": "admin",
            "createdAt": FieldValue.serverTimestamp(),
          });
          userDoc = await FirebaseFirestore.instance.collection("users_admin").doc(user.uid).get();
          isGlobalAdmin = true;
          detectedTenantId = "azienda_master";
        }

        if (isGlobalAdmin) {
          detectedTenantId ??= userDoc.data()?["tenantId"] as String?;
        } else {
          // Cerca negli users_admin nidificati (web admins)
          final nestedAdmin = await FirebaseFirestore.instance
              .collectionGroup("users_admin")
              .where("email", isEqualTo: user.email)
              .get();

          if (nestedAdmin.docs.isNotEmpty) {
            userDoc = nestedAdmin.docs.first.reference.get() as dynamic; // Cast per brevità, otterremo il doc dopo
            final doc = await nestedAdmin.docs.first.reference.get();
            userDoc = doc;
            final pathSegments = doc.reference.path.split('/');
            if (pathSegments.length >= 2) detectedTenantId = pathSegments[1];
          } else {
            // Cerca negli utenti mobile
            final tenantUsers = await FirebaseFirestore.instance
                .collectionGroup("users")
                .where("email", isEqualTo: user.email)
                .get();

            if (tenantUsers.docs.isNotEmpty) {
              final doc = await tenantUsers.docs.first.reference.get();
              userDoc = doc;
              final pathSegments = doc.reference.path.split('/');
              if (pathSegments.length >= 2) detectedTenantId = pathSegments[1];
            }
          }
        }

        if (!userDoc.exists) {
          print("🚨 [LOGIN] Utente ${user.uid} non trovato.");
          await _auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Accesso non autorizzato. Contatta l'amministratore.")),
            );
          }
          return;
        }

        final data = userDoc.data() as Map<String, dynamic>? ?? {};
        if (data["active"] == false) {
          print("🚨 [LOGIN] Utente ${user.uid} disabilitato.");
          await _auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Il tuo account è stato disabilitato.")),
            );
          }
          return;
        }

        // Persistenza TenantId nel provider locale
        if (detectedTenantId != null) {
          await ref.read(tenantProvider.notifier).setTenant(detectedTenantId);
          print("🚨 [LOGIN] Successo. Tenant associato: $detectedTenantId");

          // 🔥 SINCRONIZZA IL TOKEN FCM SUBITO DOPO IL LOGIN
          await FcmService.syncToken();
        }

        if (mounted) Navigator.pop(context, true);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

    } finally {

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          /// HERO IMAGE

          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1445205170230-053b83016050",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          /// CONTENT

          Center(
            child: SingleChildScrollView(

              padding: const EdgeInsets.all(28),

              child: Column(

                children: [

                  const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 60,
                  ),

                  const SizedBox(height: 40),

                  /// NOME NEGOZIO

                  if (isRegister)
                    TextField(
                      controller: _shopController,
                      decoration: const InputDecoration(
                        hintText: "Nome negozio",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                  if (isRegister) const SizedBox(height: 16),

                  /// EMAIL

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  /// RIPETI PASSWORD

                  if (isRegister)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          hintText: "Ripeti password",
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  /// LOGIN / REGISTER BUTTON

                  ElevatedButton(

                    onPressed: loading ? null : submit,

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),

                    child: loading
                        ? const CircularProgressIndicator()
                        : Text(isRegister ? "Registrati" : "Accedi"),

                  ),

                  const SizedBox(height: 12),

                  /// GOOGLE LOGIN

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {

                      final cred = await _auth.signInWithGoogle();

                      // Check if account exists and is active
                      var userDoc = await FirebaseFirestore.instance
                          .collection("users_admin")
                          .doc(cred.user!.uid)
                          .get();
                      bool isGlobalAdmin = userDoc.exists;
                      String? detectedTenantId;

                      if (!userDoc.exists && cred.user?.email == "s.moroni72@gmail.com") {
                        print("🚨 [LOGIN GOOGLE] Auto-creazione profilo ADMIN: ${cred.user!.email}");
                        await FirebaseFirestore.instance.collection("users_admin").doc(cred.user!.uid).set({
                          "uid": cred.user!.uid,
                          "email": cred.user!.email,
                          "displayName": cred.user!.displayName ?? "Admin",
                          "active": true,
                          "tenantId": "azienda_master",
                          "role": "admin",
                          "createdAt": FieldValue.serverTimestamp(),
                        });
                        userDoc = await FirebaseFirestore.instance.collection("users_admin").doc(cred.user!.uid).get();
                        isGlobalAdmin = true;
                        detectedTenantId = "azienda_master";
                      }

                      if (isGlobalAdmin) {
                        detectedTenantId ??= (userDoc.data() as Map?)?["tenantId"] as String?;
                      } else {
                        // Cerca in users_admin nidificati
                        final nestedAdmin = await FirebaseFirestore.instance
                            .collectionGroup("users_admin")
                            .where("email", isEqualTo: cred.user!.email)
                            .get();

                        if (nestedAdmin.docs.isNotEmpty) {
                          final doc = await nestedAdmin.docs.first.reference.get();
                          userDoc = doc;
                          final pathSegments = doc.reference.path.split('/');
                          if (pathSegments.length >= 2) detectedTenantId = pathSegments[1];
                        } else {
                          // Cerca in utenti mobile
                          final tenantUsers = await FirebaseFirestore.instance
                              .collectionGroup("users")
                              .where("email", isEqualTo: cred.user!.email)
                              .get();

                          if (tenantUsers.docs.isNotEmpty) {
                            final doc = await tenantUsers.docs.first.reference.get();
                            userDoc = doc;
                            final pathSegments = doc.reference.path.split('/');
                            if (pathSegments.length >= 2) detectedTenantId = pathSegments[1];
                          }
                        }
                      }

                      if (!userDoc.exists) {
                        print("🚨 [LOGIN GOOGLE] Utente ${cred.user!.uid} non trovato.");
                        await _auth.signOut();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Accesso non autorizzato.")),
                          );
                        }
                        return;
                      }

                      final userData = userDoc.data() as Map<String, dynamic>?;
                      if (userData?["active"] == false) {
                        print("🚨 [LOGIN GOOGLE] Utente disabilitato.");
                        await _auth.signOut();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Account disabilitato.")),
                          );
                        }
                        return;
                      }

                      // Persistenza TenantId
                      if (detectedTenantId != null) {
                        await ref.read(tenantProvider.notifier).setTenant(detectedTenantId);
                        print("🚨 [LOGIN GOOGLE] Successo. Tenant associato: $detectedTenantId");

                        // 🔥 SINCRONIZZA IL TOKEN FCM SUBITO DOPO IL LOGIN
                        await FcmService.syncToken();
                      }

                      if (mounted) Navigator.pop(context, true);

                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Accedi con Google"),
                  ),

                  const SizedBox(height: 20),

                  /// DEMO BUTTON
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.8),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: const Text(
                      "Esplora la Demo Luxury",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onPressed: loading ? null : () async {
                      setState(() { loading = true; });
                      try {
                        await _auth.loginEmail(
                          email: "demo@showroomflow.com",
                          password: "password-demo",
                        );
                        await ref.read(tenantProvider.notifier).setTenant("demo-tenant");
                        if (mounted) Navigator.pop(context, true);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Dati demo in caricamento, riprova tra un istante.")),
                          );
                        }
                      } finally {
                        if (mounted) setState(() { loading = false; });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  /// SWITCH LOGIN / REGISTER

                  TextButton(

                    onPressed: () {

                      setState(() {
                        isRegister = !isRegister;
                      });

                    },

                    child: Text(
                      isRegister
                          ? "Hai già un account? Accedi"
                          : "Non hai un account? Registrati",
                      style: const TextStyle(color: Colors.white),
                    ),

                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () async {

                      if (_emailController.text.isEmpty) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Inserisci prima la tua email"),
                          ),
                        );

                        return;
                      }

                      await _auth.resetPassword(
                        email: _emailController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email di reset inviata"),
                        ),
                      );
                    },
                    child: const Text(
                      "Password dimenticata?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}