import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_user_model.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final currentAdmin = adminProvider.currentAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Slate oscuro profesional para CRM
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QuickFood CRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  currentAdmin?.name ?? 'Administrador',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Center(
              child: Text(
                currentAdmin?.role.displayName ?? 'Admin',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'Cerrar Sesión CRM',
            onPressed: () {
              adminProvider.logoutAdmin();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: const [
          _CrmMetricsTab(),
          _CrmOrdersTab(),
          _CrmUsersTab(),
          _CrmRestaurantsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Métricas',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Usuarios CRM',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primary),
            label: 'Locales',
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 1. TAB: MÉTRICAS Y RESUMEN GENERAL (KPIs)
// ==============================================================================
class _CrmMetricsTab extends StatelessWidget {
  const _CrmMetricsTab();

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final totalOrders = orderProvider.orders.length;
    final activeOrders = orderProvider.activeOrders.length;
    final totalSales = orderProvider.orders.fold<double>(0.0, (sum, o) => sum + o.total);
    final openRestaurants = restaurantProvider.restaurants.where((r) => r.isOpen).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Control & Resumen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monitoreo en tiempo real de operaciones QuickFood',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          // Tarjetas de Métricas Principales (KPIs)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _MetricCard(
                title: 'Ventas Totales',
                value: '\$${totalSales.toStringAsFixed(2)}',
                subtitle: '+18% vs semana anterior',
                icon: Icons.payments_rounded,
                color: const Color(0xFF10B981),
              ),
              _MetricCard(
                title: 'Pedidos Activos',
                value: '$activeOrders',
                subtitle: '$totalOrders pedidos hoy',
                icon: Icons.delivery_dining_rounded,
                color: AppColors.primary,
              ),
              _MetricCard(
                title: 'Operadores CRM',
                value: '${adminProvider.adminUsers.length}',
                subtitle: 'Personal activo',
                icon: Icons.badge_rounded,
                color: const Color(0xFF3B82F6),
              ),
              _MetricCard(
                title: 'Locales Abiertos',
                value: '$openRestaurants / ${restaurantProvider.restaurants.length}',
                subtitle: 'Operando normalmente',
                icon: Icons.restaurant_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de Rendimiento de Restaurantes
          const Text(
            'Rendimiento por Categoría',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _CategoryProgressRow(label: 'Hamburguesas Gourmet', percentage: 0.85, count: '38% ventas'),
                const SizedBox(height: 12),
                _CategoryProgressRow(label: 'Pizzas Artesanales', percentage: 0.65, count: '27% ventas'),
                const SizedBox(height: 12),
                _CategoryProgressRow(label: 'Sushi & Comida Oriental', percentage: 0.45, count: '18% ventas'),
                const SizedBox(height: 12),
                _CategoryProgressRow(label: 'Pollo & Combos', percentage: 0.35, count: '17% ventas'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Últimos Pedidos Recientes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos Pedidos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ver todos ($totalOrders)',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (orderProvider.orders.isEmpty)
            const Center(child: Text('No hay pedidos registrados'))
          else
            ...orderProvider.orders.take(3).map((order) => _RecentOrderMiniCard(order: order)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  final String label;
  final double percentage;
  final String count;

  const _CategoryProgressRow({
    required this.label,
    required this.percentage,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(count, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _RecentOrderMiniCard extends StatelessWidget {
  final OrderModel order;

  const _RecentOrderMiniCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    '${order.restaurantName} • ${order.items.length} items',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
              ),
              Text(
                order.status.displayName,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. TAB: GESTIÓN DE PEDIDOS EN VIVO (CRM DISPATCHER)
// ==============================================================================
class _CrmOrdersTab extends StatefulWidget {
  const _CrmOrdersTab();

  @override
  State<_CrmOrdersTab> createState() => _CrmOrdersTabState();
}

class _CrmOrdersTabState extends State<_CrmOrdersTab> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final allOrders = orderProvider.orders;

    final filteredOrders = allOrders.where((order) {
      if (_statusFilter == 'all') return true;
      if (_statusFilter == 'active') return order.status.isActive;
      if (_statusFilter == 'completed') return !order.status.isActive;
      return order.status.name == _statusFilter;
    }).toList();

    return Column(
      children: [
        // Filtros horizontales
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos (${allOrders.length})',
                  isSelected: _statusFilter == 'all',
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'En Curso (${orderProvider.activeOrders.length})',
                  isSelected: _statusFilter == 'active',
                  onTap: () => setState(() => _statusFilter = 'active'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completados (${orderProvider.pastOrders.length})',
                  isSelected: _statusFilter == 'completed',
                  onTap: () => setState(() => _statusFilter = 'completed'),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(
                  child: Text(
                    'No hay pedidos bajo este filtro',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _CrmOrderCard(order: order);
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CrmOrderCard extends StatelessWidget {
  final OrderModel order;

  const _CrmOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del Pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: order.status.isActive
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: order.status.isActive ? AppColors.primary : Colors.green[800],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Restaurante: ${order.restaurantName}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${order.address.street} #${order.address.number}, ${order.address.city}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Items pedidos
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${item.foodItem.name}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '\$${(item.foodItem.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Acciones del Administrador en el Pedido
            if (order.status.isActive)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => orderProvider.advanceOrderStatus(order.id),
                      icon: const Icon(Icons.fast_forward_rounded, size: 18),
                      label: const Text('Avanzar Estado'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                    tooltip: 'Cancelar pedido',
                    onPressed: () => orderProvider.cancelOrder(order.id),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 3. TAB: GESTIÓN DE USUARIOS Y OPERADORES CRM
// ==============================================================================
class _CrmUsersTab extends StatelessWidget {
  const _CrmUsersTab();

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    AdminRole selectedRole = AdminRole.orderManager;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Nuevo Operador CRM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre y Apellido', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AdminRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol asignado', prefixIcon: Icon(Icons.badge_outlined)),
                  items: AdminRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null) {
                      setDialogState(() => selectedRole = newRole);
                    }
                  },
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
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;

                Provider.of<AdminProvider>(context, listen: false).addAdminUser(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  role: selectedRole,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Operador ${nameCtrl.text} agregado con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = adminProvider.adminUsers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Agregar Operador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal de Control & CRM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${users.length} operadores registrados',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...users.map(
              (user) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: user.isActive ? AppColors.primary : Colors.grey[400],
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  decoration: user.isActive ? null : TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!user.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Inactivo', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              user.role.displayName,
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Switch de Activar / Desactivar
                    Switch(
                      value: user.isActive,
                      activeColor: AppColors.primary,
                      onChanged: user.id == 'adm_001'
                          ? null // El superadmin no se puede desactivar
                          : (val) => adminProvider.toggleUserStatus(user.id),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 70), // Espacio para el FloatingActionButton
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 4. TAB: CONTROL DE RESTAURANTES Y LOCALES
// ==============================================================================
class _CrmRestaurantsTab extends StatelessWidget {
  const _CrmRestaurantsTab();

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final restaurants = restaurantProvider.restaurants;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final rest = restaurants[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  rest.logoUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.chipBackground,
                    child: const Icon(Icons.restaurant, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rest.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      '${rest.category} • ${rest.deliveryTime}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Envío: \$${rest.deliveryFee.toStringAsFixed(2)} • Rating: ⭐ ${rest.rating}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rest.isOpen ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rest.isOpen ? 'Abierto' : 'Cerrado',
                      style: TextStyle(
                        color: rest.isOpen ? Colors.green[800] : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
