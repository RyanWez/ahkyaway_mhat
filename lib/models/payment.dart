import 'dart:convert';

class Payment {
  final String id;
  final String loanId;
  double amount;
  DateTime paymentDate;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;

  Payment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.notes = '',
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanId': loanId,
    'amount': amount,
    'paymentDate': paymentDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
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
  );

  static String encode(List<Payment> payments) =>
      json.encode(payments.map((p) => p.toJson()).toList());

  static List<Payment> decode(String paymentsString) =>
      (json.decode(paymentsString) as List<dynamic>)
          .map((item) => Payment.fromJson(item))
          .toList();
}
