import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_network_image.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    // Find updated version of this order in provider
    final liveOrder = orderProvider.orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );

    final currentStep = liveOrder.status.stepIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Seguimiento • ${liveOrder.id}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Cerrar y volver al inicio',
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. SIMULATED MAP & ROUTE HEADER
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECEF),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Stylized map grid background
                  CustomPaint(
                    size: const Size(double.infinity, 190),
                    painter: _MapCanvasPainter(),
                  ),
                  // Pulse ripple around driver
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Vehicle marker
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Estimated arrival floating card
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            liveOrder.status == OrderStatus.delivered
                                ? '¡Pedido entregado con éxito!'
                                : 'Llegada estimada: ${liveOrder.estimatedDeliveryTime}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. MAIN TRACKING CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant summary
                  Row(
                    children: [
                      CustomNetworkImage(
                        imageUrl: liveOrder.restaurantBanner,
                        width: 50,
                        height: 50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              liveOrder.restaurantName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${liveOrder.totalItemCount} productos • \$${liveOrder.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. STEP PROGRESS TRACKER (5 ESTADOS)
                  const Text(
                    'Estado del pedido',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTimelineStep(
                    stepNumber: 0,
                    currentStep: currentStep,
                    title: '1. Pedido recibido',
                    subtitle: 'El restaurante ha recibido y confirmado tu orden.',
                    icon: Icons.receipt_long_rounded,
                  ),
                  _buildTimelineConnector(isDone: currentStep >= 1),
                  _buildTimelineStep(
                    stepNumber: 1,
                    currentStep: currentStep,
                    title: '2. Restaurante preparando',
                    subtitle: 'Los cocineros están preparando tus platillos frescos.',
                    icon: Icons.outdoor_grill_rounded,
                  ),
                  _buildTimelineConnector(isDone: currentStep >= 2),
                  _buildTimelineStep(
                    stepNumber: 2,
                    currentStep: currentStep,
                    title: '3. Repartidor recogiendo',
                    subtitle: '${liveOrder.driverName} llegó al local para retirar tu orden.',
                    icon: Icons.storefront_rounded,
                  ),
                  _buildTimelineConnector(isDone: currentStep >= 3),
                  _buildTimelineStep(
                    stepNumber: 3,
                    currentStep: currentStep,
                    title: '4. En camino',
                    subtitle: 'El repartidor va velozmente en camino a tu domicilio.',
                    icon: Icons.electric_moped_rounded,
                  ),
                  _buildTimelineConnector(isDone: currentStep >= 4),
                  _buildTimelineStep(
                    stepNumber: 4,
                    currentStep: currentStep,
                    title: '5. Entregado',
                    subtitle: '¡Disfruta tu comida! Gracias por preferir QuickFood.',
                    icon: Icons.check_circle_rounded,
                    isLast: true,
                  ),

                  const SizedBox(height: 24),

                  // Simulation Button for tester/evaluator convenience
                  if (liveOrder.status != OrderStatus.delivered && liveOrder.status != OrderStatus.cancelled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          orderProvider.advanceOrderStatus(liveOrder.id);
                        },
                        icon: const Icon(Icons.fast_forward_rounded),
                        label: const Text('Simular avance al siguiente estado'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                  // 4. DRIVER CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primarySoft,
                          child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                liveOrder.driverName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                liveOrder.driverVehicle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.star, size: 15),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${liveOrder.driverRating} Repartidor Pro',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        IconButton(
                          icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Llamando a ${liveOrder.driverName}...')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Abriendo chat con ${liveOrder.driverName}...')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. DELIVERY DETAILS ACCORDION
                  ExpansionTile(
                    title: const Text(
                      'Detalles de entrega y recibo',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                        title: Text(liveOrder.address.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(liveOrder.address.fullAddress),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.payment_rounded, color: AppColors.primary),
                        title: Text(liveOrder.paymentMethod.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(liveOrder.paymentMethod.subtitle),
                      ),
                      const Divider(),
                      ...liveOrder.items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${it.quantity}x ${it.foodItem.name}'),
                                Text('\$${it.totalPrice.toStringAsFixed(2)}'),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Return home button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text('Volver al inicio'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required int currentStep,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
  }) {
    final isDone = currentStep > stepNumber;
    final isCurrent = currentStep == stepNumber;

    Color stepColor;
    if (isDone) {
      stepColor = AppColors.success;
    } else if (isCurrent) {
      stepColor = AppColors.primary;
    } else {
      stepColor = AppColors.textMuted;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : (isDone ? AppColors.successSoft : AppColors.chipBackground),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : (isDone ? AppColors.success : AppColors.border),
                  width: 2,
                ),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isCurrent ? Colors.white : stepColor,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        // Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent || isDone ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent || isDone ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isDone}) {
    return Container(
      margin: const EdgeInsets.only(left: 18),
      height: 26,
      width: 2.5,
      color: isDone ? AppColors.success : AppColors.border,
    );
  }
}

// Custom painter to give map texture
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final road = Path();
    road.moveTo(0, size.height * 0.3);
    road.quadraticBezierTo(size.width * 0.4, size.height * 0.4, size.width * 0.5, size.height * 0.5);
    road.quadraticBezierTo(size.width * 0.7, size.height * 0.65, size.width, size.height * 0.4);
    canvas.drawPath(road, paintLine);

    final crossRoad = Path();
    crossRoad.moveTo(size.width * 0.5, 0);
    crossRoad.lineTo(size.width * 0.5, size.height);
    canvas.drawPath(crossRoad, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
