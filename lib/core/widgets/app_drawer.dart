import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_role_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/agent/agent_clients_screen.dart';
import '../../features/agent/agent_orders_screen.dart';
import '../../features/brands/brand_screen.dart';
import '../../features/tenant/tenant_provider.dart';
import '../../features/tenant/tenant_setup_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);
    final user = ref.watch(authStateProvider).value;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Utente"),
            accountEmail: Text(user?.email ?? "Nessun email"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFBC4A8C),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home Brands'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BrandScreen()),
              );
            },
          ),

          roleAsync.when(
            data: (role) {
              if (role == 'agent' || role == 'rappresentante' || role == 'admin') {
                return Column(
                  children: [
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "AREA RAPPRESENTANTI",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Gestione Clienti'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentClientsScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text('Gestione Ordini'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentOrdersScreen()));
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => const SizedBox.shrink(),
          ),

          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilo'),
            onTap: () {
              Navigator.pop(context);
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.business_center, color: Colors.blueGrey),
            title: const Text('Cambia Agenzia', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            subtitle: const Text('Resetta configurazione sede', style: TextStyle(fontSize: 10)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cambia Agenzia?'),
                  content: const Text('Questa operazione resetterà l\'app e dovrai scansionare un nuovo codice QR o inserire un nuovo ID agenzia.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULLA')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('RESETTA', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                // Slogghiamo anche l'utente per sicurezza o semplicemente puliamo il tenant
                await FirebaseAuth.instance.signOut();
                await ref.read(tenantProvider.notifier).clearTenant();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const TenantSetupScreen()),
                        (route) => false,
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Esci', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}