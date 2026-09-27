import 'package:flutter/material.dart';

enum PaymentType {
  card,
  cash,
  digitalWallet,
}

class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static List<PaymentMethodModel> get defaultMethods => [
    const PaymentMethodModel(
      id: 'pay_card',
      type: PaymentType.card,
      title: 'Tarjeta de Crédito / Débito',
      subtitle: '•••• •••• •••• 4589 (Visa)',
      icon: Icons.credit_card_rounded,
    ),
    const PaymentMethodModel(
      id: 'pay_digital',
      type: PaymentType.digitalWallet,
      title: 'Billetera Digital / QR',
      subtitle: 'Pago instantáneo sin contacto',
      icon: Icons.account_balance_wallet_rounded,
    ),
    const PaymentMethodModel(
      id: 'pay_cash',
      type: PaymentType.cash,
      title: 'Efectivo contra entrega',
      subtitle: 'Paga al repartidor al recibir tu pedido',
      icon: Icons.payments_outlined,
    ),
  ];
}
