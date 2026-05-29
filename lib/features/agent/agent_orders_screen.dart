import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/app_drawer.dart';
import '../auth/auth_provider.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class AgentOrdersScreen extends ConsumerStatefulWidget {
  const AgentOrdersScreen({super.key});

  @override
  ConsumerState<AgentOrdersScreen> createState() => _AgentOrdersScreenState();
}

class _AgentOrdersScreenState extends ConsumerState<AgentOrdersScreen> {
  String? _selectedClient;
  String? _selectedBrand;
  String? _selectedSeason;

  List<String> _clients = [];
  List<String> _brands = [];
  List<String> _seasons = [];

  @override
  Widget build(BuildContext context) {
    final tenantId = ref.watch(tenantIdProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Gestione Ordini'),
        backgroundColor: const Color(0xFFBC4A8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Esporta Ordini',
            onPressed: () => _exportOrders(tenantId),
          ),
        ],
      ),
      body: tenantId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('client_orders')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          // Aggiorna liste per i filtri basandoci sui dati reali
          _updateFilterLists(allDocs);

          // Filtra i documenti
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            bool matchClient = _selectedClient == null || data['clientName'] == _selectedClient;
            bool matchBrand = _selectedBrand == null || data['brandName'] == _selectedBrand;
            bool matchSeason = _selectedSeason == null || data['seasonName'] == _selectedSeason;
            return matchClient && matchBrand && matchSeason;
          }).toList();

          // Calcola totali
          int totalCapi = 0;
          double totalEuro = 0.0;
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            totalCapi += (data['itemCount'] as num? ?? 0).toInt();
            totalEuro += (data['totalAmount'] as num? ?? 0.0).toDouble();
          }

          return Column(
            children: [
              _buildSummaryBox(totalCapi, totalEuro),
              _buildFiltersBox(),
              Expanded(
                child: filteredDocs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _buildOrderCard(data);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderFormScreen()),
          );
        },
        backgroundColor: const Color(0xFFBC4A8C),
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  void _updateFilterLists(List<QueryDocumentSnapshot> docs) {
    final clients = <String>{};
    final brands = <String>{};
    final seasons = <String>{};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['clientName'] != null) clients.add(data['clientName']);
      if (data['brandName'] != null) brands.add(data['brandName']);
      if (data['seasonName'] != null) seasons.add(data['seasonName']);
    }

    _clients = clients.toList()..sort();
    _brands = brands.toList()..sort();
    _seasons = seasons.toList()..sort();
  }

  Widget _buildSummaryBox(int capi, double euro) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFBC4A8C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBC4A8C).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('TOTALE CAPI', capi.toString(), Icons.inventory_2),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSummaryItem('TOTALE EURO', '€ ${NumberFormat("#,##0.00", "it_IT").format(euro)}', Icons.euro),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildFiltersBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterChip('Cliente', _selectedClient, _clients, (val) => setState(() => _selectedClient = val))),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip('Brand', _selectedBrand, _brands, (val) => setState(() => _selectedBrand = val))),
            ],
          ),
          const SizedBox(height: 8),
          _buildFilterChip('Stagione', _selectedSeason, _seasons, (val) => setState(() => _selectedSeason = val)),
          if (_selectedClient != null || _selectedBrand != null || _selectedSeason != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _selectedClient = null;
                  _selectedBrand = null;
                  _selectedSeason = null;
                }),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('RESET FILTRI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selected, List<String> options, Function(String?) onSelected) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'ALL_VAL') {
          onSelected(null);
        } else {
          onSelected(val);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
            value: 'ALL_VAL',
            child: Text('Tutti', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))
        ),
        const PopupMenuDivider(),
        ...options.map((opt) => PopupMenuItem<String>(value: opt, child: Text(opt))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected != null ? const Color(0xFFBC4A8C).withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected != null ? const Color(0xFFBC4A8C).withOpacity(0.3) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selected ?? 'Seleziona $label',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected != null ? const Color(0xFFBC4A8C) : Colors.black54,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16, color: selected != null ? const Color(0xFFBC4A8C) : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data) {
    final date = (data['updatedAt'] as Timestamp?)?.toDate();
    final orderDate = data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : date;
    final formattedDate = orderDate != null ? DateFormat('dd/MM/yyyy').format(orderDate) : 'N/D';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailScreen(orderData: data)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['clientName']?.toUpperCase() ?? 'Cliente Ignoto',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${data['brandName'] ?? ''} • ${data['seasonName'] ?? ''}',
                style: const TextStyle(color: Color(0xFFBC4A8C), fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const Divider(height: 20, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CAPI', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text('${data['itemCount'] ?? 0}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('TOTALE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text(
                        '€ ${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFBC4A8C)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Nessun ordine trovato con questi filtri', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => setState(() {
              _selectedClient = null;
              _selectedBrand = null;
              _selectedSeason = null;
            }),
            child: const Text('Reset Filtri'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportOrders(String? tenantId) async {
    if (tenantId == null) return;

    // Recuperiamo i dati correnti filtrati
    final snapshot = await FirebaseFirestore.instance
        .collection('tenants')
        .doc(tenantId)
        .collection('client_orders')
        .orderBy('updatedAt', descending: true)
        .get();

    final docs = snapshot.docs.where((doc) {
      final data = doc.data();
      bool matchClient = _selectedClient == null || data['clientName'] == _selectedClient;
      bool matchBrand = _selectedBrand == null || data['brandName'] == _selectedBrand;
      bool matchSeason = _selectedSeason == null || data['seasonName'] == _selectedSeason;
      return matchClient && matchBrand && matchSeason;
    }).toList();

    if (docs.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessun ordine da esportare')));
      return;
    }

    String csvContent = "CLIENTE;DATA;BRAND;STAGIONE;CAPI;EURO\n";
    for (var doc in docs) {
      final data = doc.data();
      final date = (data['updatedAt'] as Timestamp?)?.toDate();
      final orderDate = data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : date;
      final d = orderDate != null ? DateFormat('dd/MM/yyyy').format(orderDate) : '';
      csvContent += "${data['clientName']};$d;${data['brandName']};${data['seasonName']};${data['itemCount']};${data['totalAmount']}\n";
    }

    await Clipboard.setData(ClipboardData(text: csvContent));

    // Salva in un file temporaneo per la condivisione
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/export_ordini.csv');
    await file.writeAsString(csvContent);

    // Apri l'intent di condivisione nativo con il file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Report Ordini Export',
      text: 'Ecco il report degli ordini esportato in CSV.',
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ordini Esportati'),
          content: const Text('Il report ordini è stato copiato negli appunti in formato CSV.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CHIUDI')),
          ],
        ),
      );
    }
  }
}
