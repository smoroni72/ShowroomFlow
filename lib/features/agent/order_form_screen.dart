import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  final String? initialClientId;

  const OrderFormScreen({
    super.key,
    this.initialClientId,
  });

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemCountController = TextEditingController(text: '0');
  final _totalAmountController = TextEditingController(text: '0.00');

  DateTime _orderDate = DateTime.now();
  String? _selectedClientId;
  String? _selectedBrandId;
  String? _selectedSeasonId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.initialClientId;
  }

  @override
  void dispose() {
    _itemCountController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBC4A8C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _orderDate) {
      setState(() {
        _orderDate = picked;
      });
    }
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null || _selectedBrandId == null || _selectedSeasonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona Cliente, Brand e Stagione')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tenantId = ref.read(tenantIdProvider);
      if (tenantId == null) throw Exception('Azienda non identificata');

      // Get all descriptions for denormalization (to match web app logic)
      final clientDoc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('clients')
          .doc(_selectedClientId)
          .get();
      final brandDoc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('brands')
          .doc(_selectedBrandId)
          .get();
      final seasonDoc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('brands')
          .doc(_selectedBrandId)
          .collection('seasons')
          .doc(_selectedSeasonId)
          .get();

      final clientData = clientDoc.data()!;
      final brandData = brandDoc.data()!;
      final seasonData = seasonDoc.data()!;

      final orderData = {
        'clientId': _selectedClientId,
        'brandId': _selectedBrandId,
        'seasonId': _selectedSeasonId,
        'itemCount': int.parse(_itemCountController.text),
        'totalAmount': double.parse(_totalAmountController.text),
        'orderDate': Timestamp.fromDate(_orderDate),
        'clientName': clientData['name'],
        'clientShopName': clientData['name'],
        'clientCity': clientData['city'] ?? '',
        'clientAddress': clientData['address'] ?? '',
        'brandName': brandData['name'],
        'seasonName': seasonData['name'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('client_orders')
          .add(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordine registrato con successo')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registra Nuovo Ordine'),
        backgroundColor: const Color(0xFFBC4A8C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('DATA ORDINE'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFBC4A8C), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_orderDate),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('SELEZIONE CLIENTE'),
              _buildClientSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('BRAND E STAGIONE'),
              _buildBrandSelector(),
              const SizedBox(height: 16),
              if (_selectedBrandId != null) _buildSeasonSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('DATI VENDITA'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _itemCountController,
                      'Numero Capi',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _totalAmountController,
                      'Totale Ordine (€)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBC4A8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'CONFERMA ORDINE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFBC4A8C), width: 1.5)),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Campo richiesto' : null,
    );
  }

  Widget _buildClientSelector() {
    final tenantId = ref.watch(tenantIdProvider);
    if (tenantId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('clients')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final clients = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedClientId,
          decoration: _selectorDecoration('Scegli un cliente...'),
          items: clients.map((doc) {
            final data = doc.data() as Map;
            return DropdownMenuItem(
              value: doc.id,
              child: Text(data['name'] ?? ''),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedClientId = val),
        );
      },
    );
  }

  Widget _buildBrandSelector() {
    final tenantId = ref.watch(tenantIdProvider);
    if (tenantId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('brands')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final brands = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedBrandId,
          decoration: _selectorDecoration('Scegli Brand...'),
          items: brands.map((doc) {
            final data = doc.data() as Map;
            return DropdownMenuItem(
              value: doc.id,
              child: Text(data['name'] ?? ''),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedBrandId = val;
              _selectedSeasonId = null; // Reset season when brand changes
            });
          },
        );
      },
    );
  }

  Widget _buildSeasonSelector() {
    final tenantId = ref.watch(tenantIdProvider);
    if (tenantId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('brands')
          .doc(_selectedBrandId)
          .collection('seasons')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final seasons = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedSeasonId,
          decoration: _selectorDecoration('Scegli Stagione...'),
          items: seasons.map((doc) {
            final data = doc.data() as Map;
            return DropdownMenuItem(
              value: doc.id,
              child: Text(data['name'] ?? ''),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedSeasonId = val),
        );
      },
    );
  }

  InputDecoration _selectorDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
