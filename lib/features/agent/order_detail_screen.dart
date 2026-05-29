import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final date = (orderData['updatedAt'] as dynamic)?.toDate();
    final formattedDate = date != null ? DateFormat('dd MMMM yyyy, HH:mm').format(date) : 'Data non disponibile';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Dettaglio Ordine'),
        backgroundColor: const Color(0xFFBC4A8C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatusHeader(formattedDate),
            const SizedBox(height: 24),
            _buildClientSection(),
            const SizedBox(height: 24),
            _buildOrderDetailsSection(),
            const SizedBox(height: 40),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String date) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ORDINE REGISTRATO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12, color: Colors.green)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection() {
    return _buildSectionCard(
      title: 'CLIENTE',
      icon: Icons.store_mall_directory_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderData['clientName']?.toUpperCase() ?? 'CLIENTE IGNOTO',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            '${orderData['clientCity'] ?? ''} - ${orderData['clientAddress'] ?? ''}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return _buildSectionCard(
      title: 'BRAND E STAGIONE',
      icon: Icons.label_important_outline,
      child: Row(
        children: [
          Expanded(
            child: _buildMiniInfo('BRAND', orderData['brandName'] ?? '-'),
          ),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(
            child: _buildMiniInfo('STAGIONE', orderData['seasonName'] ?? '-', crossAxisAlignment: CrossAxisAlignment.end),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _buildSummaryRow('TOTALE CAPI', '${orderData['itemCount'] ?? 0} UNITÀ', Colors.white30),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'TOTALE ORDINE',
            '€ ${(orderData['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
            const Color(0xFFBC4A8C),
            isLarge: true,
          ),
          const SizedBox(height: 8),
          const Text('IVA ESCLUSA', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
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
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        Text(
            value,
            style: TextStyle(
                color: color,
                fontSize: isLarge ? 28 : 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -1
            )
        ),
      ],
    );
  }
}