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
    final labelCtrl = TextEditingController(text: 'Mi Ubicación');
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
                  labelText: 'Calle principal y secundaria *',
                  prefixIcon: Icon(Icons.add_road_rounded),
                  hintText: 'Ej. Av. 6 de Diciembre y Orellana',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número / Piso / Dpto (Opcional)',
                  prefixIcon: Icon(Icons.tag_rounded),
                  hintText: 'Ej. N24-105 o Piso 3',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Referencia de entrega (Opcional)',
                  prefixIcon: Icon(Icons.explore_outlined),
                  hintText: 'Ej. Casa blanca con portón negro',
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
              if (streetCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor escribe tu calle o dirección'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final auth = Provider.of<AuthProvider>(context, listen: false);
              auth.addAddress(
                label: labelCtrl.text.trim().isEmpty ? 'Mi Ubicación' : labelCtrl.text.trim(),
                street: streetCtrl.text.trim(),
                number: numberCtrl.text.trim(),
                reference: refCtrl.text.trim(),
                city: cityCtrl.text.trim().isEmpty ? 'Quito' : cityCtrl.text.trim(),
                selectAsCurrent: true,
              );

              Navigator.pop(ctx); // Cierra dialog
              Navigator.pop(context); // Cierra modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 ¡Dirección actualizada para tu entrega!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar y Usar'),
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
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Obteniendo ubicación GPS precisa...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                SizedBox(height: 6),
                Text('Conectando con satélites...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 750), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Cierra loading dialog

      auth.updateLocationDirectly(
        label: 'Ubicación GPS',
        street: 'Av. República del Salvador y Naciones Unidas',
        number: 'E8-12',
        reference: 'Edificio Metropolitan, frente al Parque La Carolina',
        city: 'Quito',
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Cierra modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 ¡Ubicación GPS establecida: Av. República del Salvador!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    'Dirección de Entrega 📍',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '¿A dónde te enviamos tu pizza caliente?',
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

          // Botón GPS Ubicación Actual destacado
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _simulateGpsDetection(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.primary.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 18,
                      child: Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usar mi ubicación actual (GPS)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Detección automática en tiempo real',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Tus Direcciones Guardadas',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          // Lista de direcciones
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: authProvider.addresses.length,
              itemBuilder: (context, index) {
                final address = authProvider.addresses[index];
                final isSelected = selectedAddress.id == address.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        authProvider.selectAddress(address);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📍 Dirección activa: ${address.label}'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.chipBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForLabel(address.label),
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SELECCIONADA',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.fullAddress,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (address.reference.isNotEmpty)
                            Text(
                              'Ref: ${address.reference}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (authProvider.addresses.length > 1 && !isSelected)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                              onPressed: () => authProvider.removeAddress(address.id),
                            ),
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isSelected ? AppColors.primary : AppColors.border,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Botón agregar nueva dirección
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddAddressDialog(context),
              icon: const Icon(Icons.add_location_outlined),
              label: const Text('Escribir otra dirección manualmente'),
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

  IconData _getIconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('casa')) return Icons.home_rounded;
    if (lower.contains('trabajo') || lower.contains('oficina')) return Icons.work_outline_rounded;
    if (lower.contains('gps') || lower.contains('actual')) return Icons.my_location_rounded;
    return Icons.place_rounded;
  }
}
