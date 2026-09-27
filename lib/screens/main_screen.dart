import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrdersCount = orderProvider.activeOrders.length;
    final cartItemCount = cartProvider.itemCount;

    final List<Widget> screens = [
      HomeScreen(onNavigateToSearch: () => _onTabTapped(1)),
      const SearchScreen(),
      OrdersScreen(onNavigateToHome: () => _onTabTapped(0)),
      ProfileScreen(onNavigateToOrders: () => _onTabTapped(2)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Floating Cart Button with item count badge
      floatingActionButton: cartItemCount > 0 && _currentIndex != 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: Badge(
                label: Text(
                  '$cartItemCount',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                ),
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                child: const Icon(Icons.shopping_bag_rounded, size: 22),
              ),
              label: Text(
                'Carrito • \$${cartProvider.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.saved_search_rounded),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: activeOrdersCount > 0
                  ? Badge(
                      label: Text('$activeOrdersCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.receipt_long_outlined),
                    )
                  : const Icon(Icons.receipt_long_outlined),
              activeIcon: activeOrdersCount > 0
                  ? Badge(
                      label: Text('$activeOrdersCount'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.receipt_long_rounded),
                    )
                  : const Icon(Icons.receipt_long_rounded),
              label: 'Pedidos',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
