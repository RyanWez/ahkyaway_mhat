import 'dart:convert';

enum DebtStatus { active, completed }

class Debt {
  final String id;
  final String customerId;
  double principal;
  DateTime startDate;
  DateTime dueDate;
  DebtStatus status;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;
  final DateTime? deletedAt; // Soft delete timestamp

  Debt({
    required this.id,
    required this.customerId,
    required this.principal,
    required this.startDate,
    required this.dueDate,
    this.status = DebtStatus.active,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Total amount is now just the principal (no interest)
  double get totalAmount => principal;

  /// Check if this debt is deleted
  bool get isDeleted => deletedAt != null;

  /// Create a copy with updated fields
  Debt copyWith({
    double? principal,
    DateTime? startDate,
    DateTime? dueDate,
    DebtStatus? status,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool setDeletedAt = false,
  }) {
    return Debt(
      id: id,
      customerId: customerId,
      principal: principal ?? this.principal,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: setDeletedAt ? deletedAt : this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'principal': principal,
    'startDate': startDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    id: json['id'],
    customerId: json['customerId'],
    principal: (json['principal'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate']),
    dueDate: DateTime.parse(json['dueDate']),
    status: DebtStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => DebtStatus.active,
    ),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'])
        : null,
  );

  static String encode(List<Debt> debts) =>
      json.encode(debts.map((d) => d.toJson()).toList());

  static List<Debt> decode(String debtsString) =>
      (json.decode(debtsString) as List<dynamic>)
          .map((item) => Debt.fromJson(item))
          .toList();
}
