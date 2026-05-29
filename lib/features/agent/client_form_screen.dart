import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;
  final Map<String, dynamic>? initialData;

  const ClientFormScreen({
    super.key,
    this.clientId,
    this.initialData,
  });

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _vatNumberController;
  late TextEditingController _notesController;

  String? _selectedAgeRange;
  List<String> _selectedBrands = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name']);
    _emailController = TextEditingController(text: widget.initialData?['email']);
    _phoneController = TextEditingController(text: widget.initialData?['phone']);
    _addressController = TextEditingController(text: widget.initialData?['address']);
    _cityController = TextEditingController(text: widget.initialData?['city']);
    _zipCodeController = TextEditingController(text: widget.initialData?['zipCode']);
    _vatNumberController = TextEditingController(text: widget.initialData?['vatNumber']);
    _notesController = TextEditingController(text: widget.initialData?['notes']);

    _selectedAgeRange = widget.initialData?['ageRange'];
    _selectedBrands = List<String>.from(widget.initialData?['preferredBrands'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _vatNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final clientData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
        'vatNumber': _vatNumberController.text.trim(),
        'notes': _notesController.text.trim(),
        'ageRange': _selectedAgeRange,
        'preferredBrands': _selectedBrands,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final tenantId = ref.read(tenantIdProvider);
      if (tenantId == null) throw Exception('Azienda non identificata');

      if (widget.clientId == null) {
        clientData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('clients')
            .add(clientData);
      } else {
        await FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('clients')
            .doc(widget.clientId)
            .update(clientData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente salvato con successo')),
        );
        Navigator.pop(context);
        if (widget.clientId != null) Navigator.pop(context); // Se stiamo modificando, chiudi anche il dettaglio
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
        title: Text(widget.clientId == null ? 'Nuovo Cliente' : 'Modifica Cliente'),
        backgroundColor: const Color(0xFFBC4A8C),
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveClient,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('DATI IDENTIFICATIVI'),
              _buildTextField(_nameController, 'Ragione Sociale / Nome', required: true),
              Row(
                children: [
                  Expanded(child: _buildTextField(_vatNumberController, 'P.IVA')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_phoneController, 'Telefono')),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('LOCALIZZAZIONE E CONTATTI'),
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              _buildTextField(_addressController, 'Indirizzo'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'Città')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_zipCodeController, 'CAP')),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('SEGMENTAZIONE'),
              DropdownButtonFormField<String>(
                value: _selectedAgeRange,
                decoration: _inputDecoration('Fascia Età'),
                items: const [
                  DropdownMenuItem(value: '18-25', child: Text('18-25 anni')),
                  DropdownMenuItem(value: '26-35', child: Text('26-35 anni')),
                  DropdownMenuItem(value: '36-50', child: Text('36-50 anni')),
                  DropdownMenuItem(value: '50+', child: Text('oltre 50')),
                ],
                onChanged: (val) => setState(() => _selectedAgeRange = val),
              ),
              const SizedBox(height: 24),
              const Text(
                'BRAND DI RIFERIMENTO',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              _buildBrandSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('NOTE AGGIUNTIVE'),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration('Note...'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBC4A8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.clientId == null ? 'SALVA NUOVO CLIENTE' : 'AGGIORNA CLIENTE',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
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
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
        validator: required ? (val) => (val == null || val.isEmpty) ? 'Campo richiesto' : null : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFBC4A8C), width: 1.5)),
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
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final brands = snapshot.data!.docs;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: brands.map((doc) {
              final brand = doc.data() as Map;
              final brandId = doc.id;
              final isSelected = _selectedBrands.contains(brandId);

              return CheckboxListTile(
                title: Text(brand['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: isSelected,
                activeColor: const Color(0xFFBC4A8C),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedBrands.add(brandId);
                    } else {
                      _selectedBrands.remove(brandId);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}