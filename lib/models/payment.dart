import 'dart:convert';
import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 3)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String loanId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime paymentDate;

  @HiveField(4)
  String notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  final DateTime? deletedAt; // Soft delete timestamp

  Payment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.notes = '',
    required this.createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Check if this payment is deleted
  bool get isDeleted => deletedAt != null;

  /// Create a copy with updated fields
  Payment copyWith({
    double? amount,
    DateTime? paymentDate,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool setDeletedAt = false,
  }) {
    return Payment(
      id: id,
      loanId: loanId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: setDeletedAt ? deletedAt : this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'amount': amount,
    'paymentDate': paymentDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    loanId: json['loanId'],
    amount: (json['amount'] as num).toDouble(),
    paymentDate: DateTime.parse(json['paymentDate']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    // Backward compatible: use createdAt if updatedAt not present
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.parse(json['createdAt']),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'])
        : null,
  );

  static String encode(List<Payment> payments) =>
      json.encode(payments.map((p) => p.toJson()).toList());

  static List<Payment> decode(String paymentsString) =>
      (json.decode(paymentsString) as List<dynamic>)
          .map((item) => Payment.fromJson(item))
          .toList();
}
