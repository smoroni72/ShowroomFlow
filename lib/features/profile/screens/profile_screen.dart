import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../visits/screens/my_visit_requests_screen.dart';

class ProfileScreen extends StatefulWidget {

  final String initialEmail;
  final String initialContactName;

  const ProfileScreen({
    super.key,
    this.initialEmail = "",
    this.initialContactName = "",
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _shopController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _emailController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    _emailController.text = user?.email ?? "";

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();

    _emailController.text = widget.initialEmail;

    if (data != null) {

      _shopController.text = data["shopName"] ?? "";
      _contactController.text =
          data["contactName"] ?? widget.initialContactName;

      _phoneController.text = data["phone"] ?? "";
      _addressController.text = data["address"] ?? "";
      _cityController.text = data["city"] ?? "";
      _zipController.text = data["zip"] ?? "";
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "shopName": _shopController.text,
      "contactName": _contactController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "city": _cityController.text,
      "zip": _zipController.text,
      "email": _emailController.text,
    }, SetOptions(merge: true));

    if (mounted) Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profilo negozio"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          TextFormField(
            controller: _shopController,
            decoration: const InputDecoration(
              labelText: "Nome negozio",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _contactController,
            decoration: const InputDecoration(
              labelText: "Referente",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: "Email",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: "Telefono",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: "Indirizzo",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: "Città",
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _zipController,
            decoration: const InputDecoration(
              labelText: "CAP",
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: saveProfile,
            child: const Text("Salva modifiche"),
          ),

          const SizedBox(height: 10),

          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("visit_requests")
                .where(
              "userId",
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
                .limit(1)
                .get(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const SizedBox();
              }

              /// nessuna richiesta
              if (snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }

              /// almeno una richiesta → mostra bottone
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.event_note),
                  label: const Text("Le tue richieste"),
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyVisitRequestsScreen(),
                      ),
                    );

                  },
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              Navigator.pop(context);

            },
            child: const Text("Esci"),
          ),
        ],
      ),
    );
  }
}