import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'client_form_screen.dart';
import 'order_form_screen.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;
  final Map<String, dynamic> clientData;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
    required this.clientData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferredBrands = clientData['preferredBrands'] as List? ?? [];
    final tenantId = ref.watch(tenantIdProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(clientData['name'] ?? 'Dettaglio Cliente'),
        backgroundColor: const Color(0xFFBC4A8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientFormScreen(
                    clientId: clientId,
                    initialData: clientData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: 'CONTATTI E LOCALIZZAZIONE',
              children: [
                _buildInfoRow(Icons.map, 'Indirizzo', clientData['address'] ?? '-'),
                _buildInfoRow(Icons.location_city, 'Città', '${clientData['city'] ?? '-'} (${clientData['zipCode'] ?? '-'})'),
                _buildInfoRow(Icons.email, 'Email', clientData['email'] ?? '-'),
                _buildInfoRow(Icons.phone, 'Telefono', clientData['phone'] ?? '-'),
                _buildInfoRow(Icons.business, 'P.IVA', clientData['vatNumber'] ?? '-'),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'SEGMENTAZIONE',
              children: [
                _buildInfoRow(Icons.cake, 'Fascia Età', clientData['ageRange'] ?? '-'),
                const SizedBox(height: 16),
                const Text(
                  'BRAND PREFERITI / LAVORATI',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                if (preferredBrands.isEmpty)
                  const Text('Nessun brand specificato', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic))
                else if (tenantId == null)
                  const SizedBox.shrink()
                else
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tenants')
                        .doc(tenantId)
                        .collection('brands')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final brands = snapshot.data!.docs
                          .where((doc) => preferredBrands.contains(doc.id))
                          .map((doc) => (doc.data() as Map)['name'] as String)
                          .toList();

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: brands.map((name) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBC4A8C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFBC4A8C).withOpacity(0.2)),
                          ),
                          child: Text(
                            name.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBC4A8C)),
                          ),
                        )).toList(),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'NOTE AGGIUNTIVE',
              children: [
                Text(
                  clientData['notes'] != null && clientData['notes'].toString().isNotEmpty
                      ? clientData['notes']
                      : 'Nessuna nota presente.',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderFormScreen(initialClientId: clientId),
            ),
          );
        },
        backgroundColor: const Color(0xFFBC4A8C),
        label: const Text('NUOVO ORDINE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_shopping_cart),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFBC4A8C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: Color(0xFFBC4A8C), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientData['name']?.toUpperCase() ?? 'Senza Nome',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                Text(
                  clientData['city'] ?? 'Località non definita',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBC4A8C).withOpacity(0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}