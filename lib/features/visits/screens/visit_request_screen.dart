import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/providers/showroom_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitRequestScreen extends ConsumerStatefulWidget {

  final String brandId;

  const VisitRequestScreen({
    super.key,
    required this.brandId,
  });

  @override
  ConsumerState<VisitRequestScreen> createState() => _VisitRequestScreenState();
}

class _VisitRequestScreenState extends ConsumerState<VisitRequestScreen> {

  DateTime? selectedDate;
  String? selectedSlot;

  final slots = [
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00",
  ];

  Future<void> submitRequest() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data();

    await FirebaseFirestore.instance
        .collection("visit_requests")
        .add({

      "userId": user.uid,
      "shopName": userData?["shopName"] ?? "",
      "contactName": userData?["contactName"] ?? "",
      "phone": userData?["phone"] ?? "",

      "brandId": widget.brandId,

      "requestedDate": selectedDate,
      "requestedSlot": selectedSlot,

      "status": "pending",

      "createdAt": FieldValue.serverTimestamp(),

    });

    if (!mounted) return;

    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Richiedi visita"),
      ),

      body: Column(
        children: [
          _VisitHeader(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                const Text(
                  "Richiedi una visita dell'agente per visionare il campionario.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                  const SizedBox(height: 30),

                  const Text("Seleziona giorno"),

                  const SizedBox(height: 10),

                  ElevatedButton(

                    onPressed: () async {

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 60),
                        ),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },

                    child: Text(
                      selectedDate == null
                          ? "Scegli data"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text("Orario preferito"),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    children: slots.map((slot) {

                      final selected = slot == selectedSlot;

                      return ChoiceChip(
                        label: Text(slot),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            selectedSlot = slot;
                          });
                        },
                      );

                    }).toList(),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(

                      onPressed: selectedDate != null && selectedSlot != null
                          ? submitRequest
                          : null,

                      child: const Text("Invia richiesta"),

                    ),
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showSuccessDialog() {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {

        return Dialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),

                const SizedBox(height: 16),

                const Text(
                  "Richiesta inviata",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "L'agente ti contatterà presto per fissare l'appuntamento.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {

                    Navigator.pop(context); // chiude dialog
                    Navigator.pop(context); // torna alla schermata precedente

                  },
                  child: const Text("Perfetto"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

}
class _VisitHeader extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VisitHeader> createState() => _VisitHeaderState();
}

class _VisitHeaderState extends ConsumerState<_VisitHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showroomAsync = ref.watch(showroomProvider);

    return showroomAsync.when(
      loading: () => const SizedBox(height: 200),
      error: (_, __) => const SizedBox(height: 200),
      data: (data) {
        final name = data['name'] ?? 'Showroom';
        final phone = data['phone'] ?? '';
        final email = data['email'] ?? '';
        final image = data['coverImage'] ?? '';

        return SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 📸 BACKGROUND
              ProductImage(
                image: image.isNotEmpty
                    ? image
                    : 'assets/images/studio.jpg',
                fit: BoxFit.cover,
              ),

              /// 🌑 OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              /// ✨ CONTENUTO ANIMATO
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (phone.isNotEmpty || email.isNotEmpty)
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              if (phone.isNotEmpty)
                                _ContactChip(
                                  icon: Icons.phone,
                                  label: phone,
                                ),
                              if (email.isNotEmpty)
                                _ContactChip(
                                  icon: Icons.email,
                                  label: email,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactChip({
    required this.icon,
    required this.label,
  });

  Future<void> _handleTap() async {
    Uri? uri;

    /// 📞 TELEFONO
    if (icon == Icons.phone) {
      uri = Uri.parse("tel:$label");
    }

    /// ✉️ EMAIL
    if (icon == Icons.email) {
      uri = Uri.parse("mailto:$label");
    }

    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("❌ launch error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}