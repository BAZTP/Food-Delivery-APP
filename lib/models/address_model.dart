class AddressModel {
  final String id;
  final String label; // "Casa", "Oficina", "Pareja", etc.
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
    this.city = 'Ciudad',
    this.isDefault = false,
  });

  String get fullAddress => '$street #$number, $city';

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
