import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import 'error_notifier.dart';

/// Secure Storage Service with encryption support
///
/// This service uses FlutterSecureStorage for encrypted data storage.
/// On first run after upgrade, it automatically migrates data from
/// the old SharedPreferences (plaintext) to secure encrypted storage.
class StorageService extends ChangeNotifier {
  // Storage keys for secure storage
  static const String _customersKey = 'secure_customers';
  static const String _debtsKey = 'secure_loans';
  static const String _paymentsKey = 'secure_payments';
  static const String _migrationKey = 'migration_complete_v1';

  // Legacy keys for migration (SharedPreferences)
  static const String _legacyCustomersKey = 'customers';
  static const String _legacyDebtsKey = 'loans';
  static const String _legacyPaymentsKey = 'payments';

  // Secure storage instance with Android-specific options
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // encryptedSharedPreferences is deprecated and removed in v10.
      // Data is auto-migrated.
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  List<Customer> _customers = [];
  List<Debt> _debts = [];
  List<Payment> _payments = [];

  // Error state management
  StorageError? _lastError;

  /// The most recent error, if any
  StorageError? get lastError => _lastError;

  /// Whether there's an unhandled error
  bool get hasError => _lastError != null;

  /// Clear the current error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  List<Customer> get customers => _customers;
  List<Debt> get debts => _debts;
  List<Payment> get payments => _payments;

  /// Initialize storage - handles migration from legacy storage
  /// Returns true if successful, false if there were errors (check lastError)
  Future<bool> init() async {
    _lastError = null;

    try {
      // Check if migration is needed
      final isMigrated = await _checkMigrationStatus();

      if (!isMigrated) {
        await _migrateFromSharedPreferences();
      }

      // Load data from secure storage
      await _loadFromSecureStorage();
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = StorageError(
        type: StorageErrorType.initialization,
        message: 'Failed to initialize storage: $e',
        originalError: e,
      );
      debugPrint('StorageService init error: $e');

      // Attempt recovery by loading directly
      try {
        await _loadFromSecureStorage();
      } catch (loadError) {
        _lastError = StorageError(
          type: StorageErrorType.load,
          message: 'Failed to load data after init error',
          originalError: loadError,
        );
      }

      notifyListeners();
      return false;
    }
  }

  /// Check if migration has been completed
  Future<bool> _checkMigrationStatus() async {
    try {
      final value = await _secureStorage.read(key: _migrationKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Migrate data from SharedPreferences to FlutterSecureStorage
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read legacy data
      final customersData = prefs.getString(_legacyCustomersKey);
      final debtsData = prefs.getString(_legacyDebtsKey);
      final paymentsData = prefs.getString(_legacyPaymentsKey);

      // Check if there's any data to migrate
      final hasData =
          (customersData != null && customersData.isNotEmpty) ||
          (debtsData != null && debtsData.isNotEmpty) ||
          (paymentsData != null && paymentsData.isNotEmpty);

      if (hasData) {
        // Write to secure storage
        if (customersData != null && customersData.isNotEmpty) {
          await _secureStorage.write(key: _customersKey, value: customersData);
        }
        if (debtsData != null && debtsData.isNotEmpty) {
          await _secureStorage.write(key: _debtsKey, value: debtsData);
        }
        if (paymentsData != null && paymentsData.isNotEmpty) {
          await _secureStorage.write(key: _paymentsKey, value: paymentsData);
        }

        // Clear legacy data after successful migration
        await prefs.remove(_legacyCustomersKey);
        await prefs.remove(_legacyDebtsKey);
        await prefs.remove(_legacyPaymentsKey);

        debugPrint('Migration completed: Data moved to secure storage');
      }

      // Mark migration as complete
      await _secureStorage.write(key: _migrationKey, value: 'true');
    } catch (e) {
      debugPrint('Migration failed: $e');
      // Don't mark as complete if migration failed
      rethrow;
    }
  }

  /// Load all data from secure storage
  Future<void> _loadFromSecureStorage() async {
    try {
      final customersData = await _secureStorage.read(key: _customersKey);
      if (customersData != null && customersData.isNotEmpty) {
        _customers = Customer.decode(customersData);
      }

      final debtsData = await _secureStorage.read(key: _debtsKey);
      if (debtsData != null && debtsData.isNotEmpty) {
        _debts = Debt.decode(debtsData);
      }

      final paymentsData = await _secureStorage.read(key: _paymentsKey);
      if (paymentsData != null && paymentsData.isNotEmpty) {
        _payments = Payment.decode(paymentsData);
      }
    } catch (e) {
      debugPrint('Failed to load from secure storage: $e');
      _customers = [];
      _debts = [];
      _payments = [];
    }
  }

  Future<void> _saveCustomers() async {
    await _secureStorage.write(
      key: _customersKey,
      value: Customer.encode(_customers),
    );
  }

  Future<void> _saveDebts() async {
    await _secureStorage.write(key: _debtsKey, value: Debt.encode(_debts));
  }

  Future<void> _savePayments() async {
    await _secureStorage.write(
      key: _paymentsKey,
      value: Payment.encode(_payments),
    );
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
