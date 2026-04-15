import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyVisitRequestsScreen extends StatelessWidget {
  const MyVisitRequestsScreen({super.key});


  Color statusColor(String status) {

    switch (status) {
      case "accepted":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "pending":
      default:
        return Colors.orange;
    }
  }

  String statusLabel(String status) {

    switch (status) {
      case "accepted":
        return "Accettata";

      case "rejected":
        return "Rifiutata";

      case "pending":
      default:
        return "In attesa";
    }
  }


  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Devi effettuare il login")),
      );
    }

    // final query = FirebaseFirestore.instance
    //     .collection("visit_requests")
    //     .where("userId", isEqualTo: user.uid)
    //     .orderBy("createdAt", descending: true);
    final query = FirebaseFirestore.instance
        .collection("visit_requests")
        .where(
      "userId",
      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Le tue richieste"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Nessuna richiesta inviata"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              final date = (data["requestedDate"] as Timestamp?)?.toDate();
              final slot = data["requestedSlot"] ?? "";
              final status = data["status"] ?? "pending";

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ListTile(

                  leading: const Icon(Icons.storefront),

                  title: Text("Visita richiesta"),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (date != null)
                        Text(
                          "${date.day}/${date.month}/${date.year}",
                        ),

                      Text("Orario: $slot"),

                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel(status),
                          style: TextStyle(
                            color: statusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}