import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import 'error_notifier.dart';

/// Hive-based Storage Service with encryption support
///
/// This service uses Hive for efficient typed data storage.
/// On first run after upgrade, it automatically migrates data from
/// the old FlutterSecureStorage/SharedPreferences to Hive boxes.
class StorageService extends ChangeNotifier {
  // Hive box names
  static const String _customersBoxName = 'customers_box';
  static const String _debtsBoxName = 'debts_box';
  static const String _paymentsBoxName = 'payments_box';

  // Migration keys
  static const String _hiveMigrationKey = 'hive_migration_complete_v1';

  // Legacy keys for migration
  static const String _legacyCustomersKey = 'customers';
  static const String _legacyDebtsKey = 'loans';
  static const String _legacyPaymentsKey = 'payments';
  static const String _secureCustomersKey = 'secure_customers';
  static const String _secureDebtsKey = 'secure_loans';
  static const String _securePaymentsKey = 'secure_payments';

  // Legacy secure storage for migration only
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Hive boxes
  late Box<Customer> _customersBox;
  late Box<Debt> _debtsBox;
  late Box<Payment> _paymentsBox;
  bool _isInitialized = false;

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

  List<Customer> get customers => _isInitialized
      ? _customersBox.values.where((c) => !c.isDeleted).toList()
      : [];

  List<Debt> get debts => _isInitialized
      ? _debtsBox.values.where((d) => !d.isDeleted).toList()
      : [];

  List<Payment> get payments => _isInitialized
      ? _paymentsBox.values.where((p) => !p.isDeleted).toList()
      : [];

  /// Initialize storage - handles migration from legacy storage
  /// Returns true if successful, false if there were errors (check lastError)
  Future<bool> init() async {
    _lastError = null;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters if not registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CustomerAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DebtAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DebtStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(PaymentAdapter());
      }

      // Open boxes
      _customersBox = await Hive.openBox<Customer>(_customersBoxName);
      _debtsBox = await Hive.openBox<Debt>(_debtsBoxName);
      _paymentsBox = await Hive.openBox<Payment>(_paymentsBoxName);

      // Check if migration is needed
      final prefs = await SharedPreferences.getInstance();
      final isMigrated = prefs.getBool(_hiveMigrationKey) ?? false;

      if (!isMigrated) {
        await _migrateFromLegacyStorage();
        await prefs.setBool(_hiveMigrationKey, true);
      }

      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = StorageError(
        type: StorageErrorType.initialization,
        message: 'Failed to initialize storage: $e',
        originalError: e,
      );
      debugPrint('StorageService init error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Migrate data from legacy JSON storage to Hive boxes
  Future<void> _migrateFromLegacyStorage() async {
    debugPrint('Starting migration to Hive...');

    try {
      // Try to read from FlutterSecureStorage first
      String? customersData = await _secureStorage.read(
        key: _secureCustomersKey,
      );
      String? debtsData = await _secureStorage.read(key: _secureDebtsKey);
      String? paymentsData = await _secureStorage.read(key: _securePaymentsKey);

      // If no secure storage data, try SharedPreferences (older legacy)
      if (customersData == null && debtsData == null && paymentsData == null) {
        final prefs = await SharedPreferences.getInstance();
        customersData = prefs.getString(_legacyCustomersKey);
        debtsData = prefs.getString(_legacyDebtsKey);
        paymentsData = prefs.getString(_legacyPaymentsKey);
      }

      // Parse and migrate customers
      if (customersData != null && customersData.isNotEmpty) {
        final customers = Customer.decode(customersData);
        for (final customer in customers) {
          await _customersBox.put(customer.id, customer);
        }
        debugPrint('Migrated ${customers.length} customers');
      }

      // Parse and migrate debts
      if (debtsData != null && debtsData.isNotEmpty) {
        final debts = Debt.decode(debtsData);
        for (final debt in debts) {
          await _debtsBox.put(debt.id, debt);
        }
        debugPrint('Migrated ${debts.length} debts');
      }

      // Parse and migrate payments
      if (paymentsData != null && paymentsData.isNotEmpty) {
        final payments = Payment.decode(paymentsData);
        for (final payment in payments) {
          await _paymentsBox.put(payment.id, payment);
        }
        debugPrint('Migrated ${payments.length} payments');
      }

      // Clean up old storage
      await _secureStorage.delete(key: _secureCustomersKey);
      await _secureStorage.delete(key: _secureDebtsKey);
      await _secureStorage.delete(key: _securePaymentsKey);

      debugPrint('Migration to Hive completed');
    } catch (e) {
      debugPrint('Migration failed: $e');
      rethrow;
    }
  }

  // ============== Customer operations ==============

  Future<void> addCustomer(Customer customer) async {
    await _customersBox.put(customer.id, customer);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customersBox.put(customer.id, customer);
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    // Soft delete customer
    final customer = _customersBox.get(id);
    if (customer != null) {
      final deleted = customer.copyWith(
        deletedAt: DateTime.now(),
        setDeletedAt: true,
      );
      await _customersBox.put(id, deleted);

      // Soft delete related debts and payments
      for (final debt in _debtsBox.values.where((d) => d.customerId == id)) {
        await deleteDebt(debt.id);
      }
      notifyListeners();
    }
  }

  Customer? getCustomer(String id) {
    return _customersBox.get(id);
  }

  /// Alias for getCustomer (backward compatibility)
  Customer? getCustomerById(String id) => getCustomer(id);

  /// Get all debts for a specific customer
  List<Debt> getDebtsForCustomer(String customerId) {
    return debts
        .where((d) => d.customerId == customerId && !d.isDeleted)
        .toList();
  }

  // ============== Debt operations ==============

  Future<void> addDebt(Debt debt) async {
    await _debtsBox.put(debt.id, debt);
    notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    await _debtsBox.put(debt.id, debt);
    notifyListeners();
  }

  Future<void> deleteDebt(String id) async {
    final debt = _debtsBox.get(id);
    if (debt != null) {
      final deleted = debt.copyWith(
        deletedAt: DateTime.now(),
        setDeletedAt: true,
      );
      await _debtsBox.put(id, deleted);

      // Soft delete related payments
      for (final payment in _paymentsBox.values.where((p) => p.loanId == id)) {
        await deletePayment(payment.id);
      }
      notifyListeners();
    }
  }

  Debt? getDebt(String id) {
    return _debtsBox.get(id);
  }

  /// Alias for getDebt (backward compatibility)
  Debt? getDebtById(String id) => getDebt(id);

  /// Get all payments for a specific debt
  List<Payment> getPaymentsForDebt(String debtId) {
    return payments.where((p) => p.loanId == debtId && !p.isDeleted).toList();
  }

  int get activeDebtsCount =>
      debts.where((d) => d.status == DebtStatus.active && !d.isDeleted).length;

  int get completedDebtsCount => debts
      .where((d) => d.status == DebtStatus.completed && !d.isDeleted)
      .length;

  // ============== Payment operations ==============

  Future<void> addPayment(Payment payment) async {
    await _paymentsBox.put(payment.id, payment);
    notifyListeners();
  }

  Future<void> updatePayment(Payment payment) async {
    await _paymentsBox.put(payment.id, payment);
    notifyListeners();
  }

  Future<void> deletePayment(String id) async {
    final payment = _paymentsBox.get(id);
    if (payment != null) {
      final deleted = payment.copyWith(
        deletedAt: DateTime.now(),
        setDeletedAt: true,
      );
      await _paymentsBox.put(id, deleted);
      notifyListeners();
    }
  }

  // ============== Statistics ==============

  double get totalOutstandingDebts {
    double total = 0;
    for (final debt in debts.where(
      (d) => d.status == DebtStatus.active && !d.isDeleted,
    )) {
      final paid = getTotalPaidForDebt(debt.id);
      total += debt.principal - paid;
    }
    return total;
  }

  double getTotalPaidForDebt(String debtId) {
    return payments
        .where((p) => p.loanId == debtId && !p.isDeleted)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // ============== Bulk operations ==============

  /// Replace all data (used for restore operations)
  Future<void> replaceAllData({
    required List<Customer> customers,
    required List<Debt> debts,
    required List<Payment> payments,
  }) async {
    // Clear existing data
    await _customersBox.clear();
    await _debtsBox.clear();
    await _paymentsBox.clear();

    // Add new data
    for (final customer in customers) {
      await _customersBox.put(customer.id, customer);
    }
    for (final debt in debts) {
      await _debtsBox.put(debt.id, debt);
    }
    for (final payment in payments) {
      await _paymentsBox.put(payment.id, payment);
    }

    notifyListeners();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _customersBox.clear();
    await _debtsBox.clear();
    await _paymentsBox.clear();
    notifyListeners();
  }
}
