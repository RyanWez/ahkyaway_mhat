import 'package:flutter/material.dart';
import 'package:ahkyaway_mhat/models/customer.dart';
import 'package:ahkyaway_mhat/models/debt.dart';
import 'package:ahkyaway_mhat/models/payment.dart';
import 'package:ahkyaway_mhat/services/storage_service.dart';

/// Mock implementation of StorageService for testing
/// Uses in-memory lists instead of FlutterSecureStorage
class MockStorageService extends ChangeNotifier implements StorageService {
  List<Customer> _customers = [];
  List<Debt> _debts = [];
  List<Payment> _payments = [];

  @override
  List<Customer> get customers => _customers;

  @override
  List<Debt> get debts => _debts;

  @override
  List<Payment> get payments => _payments;

  @override
  Future<void> init() async {
    // No initialization needed for mock
  }

  // Customer operations
  @override
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    notifyListeners();
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    _customers.removeWhere((c) => c.id == customerId);
    _debts.removeWhere((d) => d.customerId == customerId);
    final debtIds = _debts
        .where((d) => d.customerId == customerId)
        .map((d) => d.id)
        .toSet();
    _payments.removeWhere((p) => debtIds.contains(p.loanId));
    notifyListeners();
  }

  @override
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Debt operations
  @override
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    notifyListeners();
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    final index = _debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      _debts[index] = debt;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteDebt(String debtId) async {
    _debts.removeWhere((d) => d.id == debtId);
    _payments.removeWhere((p) => p.loanId == debtId);
    notifyListeners();
  }

  @override
  List<Debt> getDebtsForCustomer(String customerId) {
    return _debts.where((d) => d.customerId == customerId).toList();
  }

  @override
  Debt? getDebtById(String id) {
    try {
      return _debts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Payment operations
  @override
  Future<void> addPayment(Payment payment) async {
    _payments.add(payment);
    notifyListeners();
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    final payment = _payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );
    final debtId = payment.loanId;
    _payments.removeWhere((p) => p.id == paymentId);

    final debt = getDebtById(debtId);
    if (debt != null && debt.status == DebtStatus.completed) {
      final totalPaid = getTotalPaidForDebt(debtId);
      final remaining = debt.totalAmount - totalPaid;
      if (remaining > 0) {
        debt.status = DebtStatus.active;
        debt.updatedAt = DateTime.now();
      }
    }
    notifyListeners();
  }

  @override
  List<Payment> getPaymentsForDebt(String debtId) {
    return _payments.where((p) => p.loanId == debtId).toList();
  }

  @override
  double getTotalPaidForDebt(String debtId) {
    return _payments
        .where((p) => p.loanId == debtId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // Summary stats
  @override
  double get totalOutstandingDebts {
    double total = 0;
    for (final debt in _debts.where((d) => d.status == DebtStatus.active)) {
      total += debt.totalAmount - getTotalPaidForDebt(debt.id);
    }
    return total;
  }

  @override
  int get activeDebtsCount =>
      _debts.where((d) => d.status == DebtStatus.active).length;

  @override
  int get completedDebtsCount =>
      _debts.where((d) => d.status == DebtStatus.completed).length;

  @override
  Future<void> replaceAllData({
    required List<Customer> customers,
    required List<Debt> debts,
    required List<Payment> payments,
  }) async {
    _customers = List.from(customers);
    _debts = List.from(debts);
    _payments = List.from(payments);
    notifyListeners();
  }

  /// Helper: Seed mock data for testing
  void seedData({
    List<Customer>? customers,
    List<Debt>? debts,
    List<Payment>? payments,
  }) {
    if (customers != null) _customers = List.from(customers);
    if (debts != null) _debts = List.from(debts);
    if (payments != null) _payments = List.from(payments);
    notifyListeners();
  }

  /// Helper: Clear all data
  void clearAll() {
    _customers = [];
    _debts = [];
    _payments = [];
    notifyListeners();
  }
}
