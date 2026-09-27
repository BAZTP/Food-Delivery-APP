import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/empty_state_view.dart';
import '../cart/cart_screen.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback onNavigateToHome;

  const OrdersScreen({
    super.key,
    required this.onNavigateToHome,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrders = orderProvider.activeOrders;
    final pastOrders = orderProvider.pastOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          tabs: [
            Tab(text: 'En curso (${activeOrders.length})'),
            Tab(text: 'Historial (${pastOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Orders Tab
          _buildOrdersList(
            context,
            orders: activeOrders,
            emptyIcon: Icons.moped_outlined,
            emptyTitle: 'No tienes pedidos en curso',
            emptySubtitle: 'Cuando realices un pedido podrás seguirlo en tiempo real aquí.',
            isActiveTab: true,
          ),
          // Past Orders Tab
          _buildOrdersList(
            context,
            orders: pastOrders,
            emptyIcon: Icons.history_rounded,
            emptyTitle: 'Sin pedidos anteriores',
            emptySubtitle: 'Tus pedidos completados se mostrarán en esta sección.',
            isActiveTab: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context, {
    required List<OrderModel> orders,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required bool isActiveTab,
  }) {
    if (orders.isEmpty) {
      return EmptyStateView(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptySubtitle,
        buttonText: 'Explorar menú',
        onButtonPressed: widget.onNavigateToHome,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Restaurant & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: order.restaurantBanner,
                          width: 44,
                          height: 44,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              dateFormat.format(order.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.status == OrderStatus.delivered
                            ? AppColors.successSoft
                            : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: order.status == OrderStatus.delivered
                              ? AppColors.success
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // Items list summary
                ...order.items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${it.quantity}x ${it.foodItem.name}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 10),

                // Total and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    if (order.status.isActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingScreen(order: order),
                            ),
                          );
                        },
                        icon: const Icon(Icons.navigation_outlined, size: 16),
                        label: const Text('Seguir pedido', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => _reorder(context, order),
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Pedir de nuevo', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _reorder(BuildContext context, OrderModel order) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final restProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final restaurant = restProvider.getRestaurantById(order.restaurantId);

    if (restaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este restaurante ya no está disponible.')),
      );
      return;
    }

    cartProvider.clearCart();
    for (final item in order.items) {
      cartProvider.addItem(item.foodItem, restaurant, quantity: item.quantity);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Productos agregados al carrito de nuevo'),
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: AppColors.primary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}
