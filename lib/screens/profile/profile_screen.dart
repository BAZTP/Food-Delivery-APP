import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onNavigateToOrders;

  const ProfileScreen({
    super.key,
    required this.onNavigateToOrders,
  });

  void _showEditProfileDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              auth.updateProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddressManager(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Mis Direcciones Guardadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...auth.addresses.map((addr) {
              final isCurrent = auth.selectedAddress.id == addr.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primarySoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCurrent ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      addr.label.toLowerCase().contains('oficina')
                          ? Icons.business_rounded
                          : Icons.home_rounded,
                      color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      addr.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: () {
                        auth.removeAddress(addr.id);
                      },
                    ),
                    onTap: () {
                      auth.selectAddress(addr);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddAddressSheet(context);
                },
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Agregar nueva dirección'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final labelCtrl = TextEditingController(text: 'Mi Lugar');
    final streetCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Dirección'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Etiqueta (Casa, Oficina...)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: 'Calle'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(labelText: 'Número'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(labelText: 'Referencia'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (streetCtrl.text.trim().isNotEmpty) {
                Provider.of<AuthProvider>(context, listen: false).addAddress(
                  label: labelCtrl.text.trim().isEmpty ? 'Mi Ubicación' : labelCtrl.text.trim(),
                  street: streetCtrl.text.trim(),
                  number: numberCtrl.text.trim(),
                  reference: refCtrl.text.trim(),
                  selectAsCurrent: true,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📍 Dirección guardada y establecida como principal'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final orderProvider = Provider.of<OrderProvider>(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Iniciar Sesión'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. USER PROFILE CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    tooltip: 'Editar datos',
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. QUICK STATS
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    title: 'Pedidos',
                    value: '${orderProvider.orders.length}',
                    icon: Icons.receipt_long_rounded,
                    onTap: onNavigateToOrders,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    title: 'Direcciones',
                    value: '${auth.addresses.length}',
                    icon: Icons.place_outlined,
                    onTap: () => _showAddressManager(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    title: 'Nivel',
                    value: 'Foodie Pro',
                    icon: Icons.workspace_premium_rounded,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. SETTINGS & OPTIONS
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Direcciones de entrega',
                    subtitle: auth.selectedAddress.fullAddress,
                    onTap: () => _showAddressManager(context),
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.history_rounded,
                    title: 'Historial de pedidos',
                    subtitle: 'Ver tus órdenes pasadas',
                    onTap: onNavigateToOrders,
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.payment_outlined,
                    title: 'Métodos de pago',
                    subtitle: 'Tarjetas, billeteras y efectivo',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gestiona tus pagos en la pantalla de checkout.')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notificaciones push',
                    subtitle: 'Ofertas exclusivas y estado de envíos',
                    trailing: Switch(
                      value: true,
                      activeColor: AppColors.primary,
                      onChanged: (val) {},
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Centro de ayuda y soporte',
                    subtitle: 'Preguntas frecuentes y atención 24/7',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Soporte QuickFood: soporte@quickfood.app')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. LOGOUT BUTTON
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('¿Cerrar sesión?'),
                      content: const Text('Tendrás que iniciar sesión nuevamente para hacer pedidos.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () {
                            Navigator.pop(ctx);
                            auth.logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

            const SizedBox(height: 20),

            // App branding tag
            const Text(
              'QuickFood App v1.0.0 • Hecho con Flutter & Material 3',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
