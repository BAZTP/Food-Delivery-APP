class AddressModel {
  final String id;
  final String label; // "Casa", "Trabajo", "Ubicación Actual", etc.
  final String street;
  final String number;
  final String reference;
  final String city;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.street,
    required this.number,
    this.reference = '',
    this.city = 'Quito',
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = <String>[];
    if (street.trim().isNotEmpty) {
      parts.add(street.trim());
    }
    if (number.trim().isNotEmpty) {
      final cleanNum = number.trim();
      parts.add(cleanNum.startsWith('#') ? cleanNum : '#$cleanNum');
    }
    if (city.trim().isNotEmpty && !street.toLowerCase().contains(city.trim().toLowerCase())) {
      parts.add(city.trim());
    }
    return parts.isEmpty ? 'Ubicación seleccionada' : parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'street': street,
        'number': number,
        'reference': reference,
        'city': city,
        'isDefault': isDefault,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as String? ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: json['label'] as String? ?? 'Mi Dirección',
        street: json['street'] as String? ?? '',
        number: json['number'] as String? ?? '',
        reference: json['reference'] as String? ?? '',
        city: json['city'] as String? ?? 'Quito',
        isDefault: json['isDefault'] as bool? ?? false,
      );

  AddressModel copyWith({
    String? id,
    String? label,
    String? street,
    String? number,
    String? reference,
    String? city,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      number: number ?? this.number,
      reference: reference ?? this.reference,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
