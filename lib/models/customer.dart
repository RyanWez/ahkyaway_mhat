import 'dart:convert';

class Customer {
  final String id;
  String name;
  String phone;
  String address;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;
  final DateTime? deletedAt; // Soft delete timestamp

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Check if this customer is deleted
  bool get isDeleted => deletedAt != null;

  /// Create a copy with updated fields
  Customer copyWith({
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool setDeletedAt = false, // Use this to explicitly set deletedAt
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: setDeletedAt ? deletedAt : this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'])
        : null,
  );

  static String encode(List<Customer> customers) =>
      json.encode(customers.map((c) => c.toJson()).toList());

  static List<Customer> decode(String customersString) =>
      (json.decode(customersString) as List<dynamic>)
          .map((item) => Customer.fromJson(item))
          .toList();
}
