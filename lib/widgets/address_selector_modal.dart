import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class AddressSelectorModal extends StatelessWidget {
  const AddressSelectorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressSelectorModal(),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Quito');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_location_alt_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Nueva Dirección', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Etiqueta (Ej. Casa, Oficina, Pareja)',
                  prefixIcon: Icon(Icons.bookmark_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Calle principal y secundaria',
                  prefixIcon: Icon(Icons.add_road_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número / Piso / Dpto',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Referencia de entrega',
                  prefixIcon: Icon(Icons.explore_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
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
              if (streetCtrl.text.trim().isEmpty || numberCtrl.text.trim().isEmpty) return;

              final auth = Provider.of<AuthProvider>(context, listen: false);
              auth.addAddress(
                label: labelCtrl.text.trim().isEmpty ? 'Mi Ubicación' : labelCtrl.text.trim(),
                street: streetCtrl.text.trim(),
                number: numberCtrl.text.trim(),
                reference: refCtrl.text.trim(),
                city: cityCtrl.text.trim(),
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Dirección guardada exitosamente!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _simulateGpsDetection(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Obteniendo ubicación GPS precisa...', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Cierra loading dialog
      auth.addAddress(
        label: 'Ubicación Actual (GPS)',
        street: 'Av. de los Shyris y Naciones Unidas',
        number: 'E8-12',
        reference: 'Frente al parque La Carolina',
        city: 'Quito',
      );
      if (!context.mounted) return;
      Navigator.pop(context); // Cierra modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Ubicación GPS establecida: Av. Shyris y Naciones Unidas'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedAddress = authProvider.selectedAddress;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dirección de Entrega',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '¿A dónde te llevamos tu pedido?',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botón GPS Ubicación Actual
          InkWell(
            onTap: () => _simulateGpsDetection(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usar mi ubicación actual (GPS)',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          'Detectar automáticamente con un toque',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Tus Direcciones Guardadas',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          // Lista de direcciones
          ...authProvider.addresses.map((address) {
            final isSelected = selectedAddress.id == address.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  onTap: () {
                    authProvider.selectAddress(address);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.chipBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      address.label.toLowerCase().contains('trabajo') ||
                              address.label.toLowerCase().contains('oficina')
                          ? Icons.work_outline_rounded
                          : Icons.home_rounded,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        address.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ACTUAL',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    address.fullAddress,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.border),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Botón agregar nueva dirección
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddAddressDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar otra dirección'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
