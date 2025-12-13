import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';

class StorageService extends ChangeNotifier {
  static const String _customersKey = 'customers';
  static const String _debtsKey =
      'loans'; // Keep same key for backward compatibility
  static const String _paymentsKey = 'payments';

  List<Customer> _customers = [];
  List<Debt> _debts = [];
  List<Payment> _payments = [];

  List<Customer> get customers => _customers;
  List<Debt> get debts => _debts;
  List<Payment> get payments => _payments;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final customersData = prefs.getString(_customersKey);
    if (customersData != null && customersData.isNotEmpty) {
      _customers = Customer.decode(customersData);
    }

    final debtsData = prefs.getString(_debtsKey);
    if (debtsData != null && debtsData.isNotEmpty) {
      _debts = Debt.decode(debtsData);
    }

    final paymentsData = prefs.getString(_paymentsKey);
    if (paymentsData != null && paymentsData.isNotEmpty) {
      _payments = Payment.decode(paymentsData);
    }

    notifyListeners();
  }

  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customersKey, Customer.encode(_customers));
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_debtsKey, Debt.encode(_debts));
  }

  Future<void> _savePayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentsKey, Payment.encode(_payments));
  }

  // Customer operations
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _saveCustomers();
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      await _saveCustomers();
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    _customers.removeWhere((c) => c.id == customerId);
    _debts.removeWhere((d) => d.customerId == customerId);
    final debtIds = _debts
        .where((d) => d.customerId == customerId)
        .map((d) => d.id)
        .toSet();
    _payments.removeWhere((p) => debtIds.contains(p.loanId));
    await _saveCustomers();
    await _saveDebts();
    await _savePayments();
    notifyListeners();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Debt operations
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    await _saveDebts();
    notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    final index = _debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      _debts[index] = debt;
      await _saveDebts();
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String debtId) async {
    _debts.removeWhere((d) => d.id == debtId);
    _payments.removeWhere((p) => p.loanId == debtId);
    await _saveDebts();
    await _savePayments();
    notifyListeners();
  }

  List<Debt> getDebtsForCustomer(String customerId) {
    return _debts.where((d) => d.customerId == customerId).toList();
  }

  Debt? getDebtById(String id) {
    try {
      return _debts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Payment operations
  Future<void> addPayment(Payment payment) async {
    _payments.add(payment);
    await _savePayments();
    notifyListeners();
  }

  Future<void> deletePayment(String paymentId) async {
    // Find the payment before deleting to get its debtId
    final payment = _payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );
    final debtId = payment.loanId;

    // Remove the payment
    _payments.removeWhere((p) => p.id == paymentId);
    await _savePayments();

    // Check if debt needs to be reactivated
    final debt = getDebtById(debtId);
    if (debt != null && debt.status == DebtStatus.completed) {
      final totalPaid = getTotalPaidForDebt(debtId);
      final remaining = debt.totalAmount - totalPaid;

      // If remaining > 0, reactivate the debt
      if (remaining > 0) {
        debt.status = DebtStatus.active;
        debt.updatedAt = DateTime.now();
        await _saveDebts();
      }
    }

    notifyListeners();
  }

  List<Payment> getPaymentsForDebt(String debtId) {
    return _payments.where((p) => p.loanId == debtId).toList();
  }

  double getTotalPaidForDebt(String debtId) {
    return _payments
        .where((p) => p.loanId == debtId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // Summary stats
  double get totalOutstandingDebts {
    double total = 0;
    for (final debt in _debts.where((d) => d.status == DebtStatus.active)) {
      total += debt.totalAmount - getTotalPaidForDebt(debt.id);
    }
    return total;
  }

  int get activeDebtsCount =>
      _debts.where((d) => d.status == DebtStatus.active).length;

  int get completedDebtsCount =>
      _debts.where((d) => d.status == DebtStatus.completed).length;

  /// Replace all data with import data (used for restore)
  Future<void> replaceAllData({
    required List<Customer> customers,
    required List<Debt> debts,
    required List<Payment> payments,
  }) async {
    _customers = List.from(customers);
    _debts = List.from(debts);
    _payments = List.from(payments);

    await _saveCustomers();
    await _saveDebts();
    await _savePayments();
    notifyListeners();
  }
}
