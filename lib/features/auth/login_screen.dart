import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../profile/screens/profile_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(
              initialEmail: _emailController.text.trim(),
              initialContactName: "",
            ),
          ),
        );

        return;

      } else {

        await _auth.loginEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

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

                      final userDoc = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(cred.user!.uid)
                          .get();

                      final data = userDoc.data();

                      final shopName = data?["shopName"] ?? "";

                      /// se il profilo non è compilato
                      if (shopName.isEmpty) {

                        if (!mounted) return;

                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              initialEmail: cred.user?.email ?? "",
                              initialContactName: cred.user?.displayName ?? "",
                            ),
                          ),
                        );

                      } else {

                        if (mounted) Navigator.pop(context, true);

                      }

                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Accedi con Google"),
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