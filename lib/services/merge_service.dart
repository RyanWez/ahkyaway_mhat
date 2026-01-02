import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';

/// Result of a merge operation showing what changed
class MergeResult {
  final List<Customer> customers;
  final List<Debt> debts;
  final List<Payment> payments;
  final MergeStats stats;

  MergeResult({
    required this.customers,
    required this.debts,
    required this.payments,
    required this.stats,
  });
}

/// Statistics about the merge operation
class MergeStats {
  final int customersFromLocal;
  final int customersFromCloud;
  final int customersUpdatedFromCloud;
  final int customersUpdatedFromLocal;

  final int debtsFromLocal;
  final int debtsFromCloud;
  final int debtsUpdatedFromCloud;
  final int debtsUpdatedFromLocal;

  final int paymentsFromLocal;
  final int paymentsFromCloud;
  final int paymentsUpdatedFromCloud;
  final int paymentsUpdatedFromLocal;

  MergeStats({
    this.customersFromLocal = 0,
    this.customersFromCloud = 0,
    this.customersUpdatedFromCloud = 0,
    this.customersUpdatedFromLocal = 0,
    this.debtsFromLocal = 0,
    this.debtsFromCloud = 0,
    this.debtsUpdatedFromCloud = 0,
    this.debtsUpdatedFromLocal = 0,
    this.paymentsFromLocal = 0,
    this.paymentsFromCloud = 0,
    this.paymentsUpdatedFromCloud = 0,
    this.paymentsUpdatedFromLocal = 0,
  });

  /// Total new items added
  int get totalNewFromLocal =>
      customersFromLocal + debtsFromLocal + paymentsFromLocal;
  int get totalNewFromCloud =>
      customersFromCloud + debtsFromCloud + paymentsFromCloud;

  /// Total items updated (conflicts resolved)
  int get totalUpdatedFromCloud =>
      customersUpdatedFromCloud +
      debtsUpdatedFromCloud +
      paymentsUpdatedFromCloud;
  int get totalUpdatedFromLocal =>
      customersUpdatedFromLocal +
      debtsUpdatedFromLocal +
      paymentsUpdatedFromLocal;

  /// Check if any changes occurred
  bool get hasChanges =>
      totalNewFromLocal > 0 ||
      totalNewFromCloud > 0 ||
      totalUpdatedFromCloud > 0 ||
      totalUpdatedFromLocal > 0;

  /// Summary description
  String get summary {
    final parts = <String>[];

    if (customersFromLocal > 0) {
      parts.add('$customersFromLocal new customer(s) from local');
    }
    if (customersFromCloud > 0) {
      parts.add('$customersFromCloud new customer(s) from cloud');
    }
    if (customersUpdatedFromCloud > 0) {
      parts.add('$customersUpdatedFromCloud customer(s) updated (cloud newer)');
    }
    if (customersUpdatedFromLocal > 0) {
      parts.add('$customersUpdatedFromLocal customer(s) kept (local newer)');
    }

    if (debtsFromLocal > 0) {
      parts.add('$debtsFromLocal new debt(s) from local');
    }
    if (debtsFromCloud > 0) {
      parts.add('$debtsFromCloud new debt(s) from cloud');
    }
    if (debtsUpdatedFromCloud > 0) {
      parts.add('$debtsUpdatedFromCloud debt(s) updated (cloud newer)');
    }
    if (debtsUpdatedFromLocal > 0) {
      parts.add('$debtsUpdatedFromLocal debt(s) kept (local newer)');
    }

    if (paymentsFromLocal > 0) {
      parts.add('$paymentsFromLocal new payment(s) from local');
    }
    if (paymentsFromCloud > 0) {
      parts.add('$paymentsFromCloud new payment(s) from cloud');
    }
    if (paymentsUpdatedFromCloud > 0) {
      parts.add('$paymentsUpdatedFromCloud payment(s) updated (cloud newer)');
    }
    if (paymentsUpdatedFromLocal > 0) {
      parts.add('$paymentsUpdatedFromLocal payment(s) kept (local newer)');
    }

    return parts.isEmpty ? 'No changes detected' : parts.join('\n');
  }
}

/// Service for intelligent merging of local and cloud data
class MergeService {
  /// Merge local and cloud data using updatedAt timestamps
  ///
  /// Algorithm:
  /// 1. For items with same ID: keep the one with newer updatedAt
  /// 2. For unique items: include both (no data loss)
  static MergeResult merge({
    required List<Customer> localCustomers,
    required List<Debt> localDebts,
    required List<Payment> localPayments,
    required List<Customer> cloudCustomers,
    required List<Debt> cloudDebts,
    required List<Payment> cloudPayments,
  }) {
    // Track statistics
    int customersFromLocal = 0;
    int customersFromCloud = 0;
    int customersUpdatedFromCloud = 0;
    int customersUpdatedFromLocal = 0;

    int debtsFromLocal = 0;
    int debtsFromCloud = 0;
    int debtsUpdatedFromCloud = 0;
    int debtsUpdatedFromLocal = 0;

    int paymentsFromLocal = 0;
    int paymentsFromCloud = 0;
    int paymentsUpdatedFromCloud = 0;
    int paymentsUpdatedFromLocal = 0;

    // Merge Customers
    final localCustomerMap = {for (var c in localCustomers) c.id: c};
    final cloudCustomerMap = {for (var c in cloudCustomers) c.id: c};
    final mergedCustomers = <Customer>[];

    // Process all cloud customers
    for (final cloudCustomer in cloudCustomers) {
      final localCustomer = localCustomerMap[cloudCustomer.id];
      if (localCustomer == null) {
        // Unique to cloud - add it
        mergedCustomers.add(cloudCustomer);
        customersFromCloud++;
      } else {
        // Exists in both - compare timestamps
        if (cloudCustomer.updatedAt.isAfter(localCustomer.updatedAt)) {
          mergedCustomers.add(cloudCustomer);
          customersUpdatedFromCloud++;
        } else {
          mergedCustomers.add(localCustomer);
          if (localCustomer.updatedAt.isAfter(cloudCustomer.updatedAt)) {
            customersUpdatedFromLocal++;
          }
          // If same timestamp, keep local (no count increment)
        }
      }
    }

    // Add customers unique to local
    for (final localCustomer in localCustomers) {
      if (!cloudCustomerMap.containsKey(localCustomer.id)) {
        mergedCustomers.add(localCustomer);
        customersFromLocal++;
      }
    }

    // Merge Debts
    final localDebtMap = {for (var d in localDebts) d.id: d};
    final cloudDebtMap = {for (var d in cloudDebts) d.id: d};
    final mergedDebts = <Debt>[];

    for (final cloudDebt in cloudDebts) {
      final localDebt = localDebtMap[cloudDebt.id];
      if (localDebt == null) {
        mergedDebts.add(cloudDebt);
        debtsFromCloud++;
      } else {
        if (cloudDebt.updatedAt.isAfter(localDebt.updatedAt)) {
          mergedDebts.add(cloudDebt);
          debtsUpdatedFromCloud++;
        } else {
          mergedDebts.add(localDebt);
          if (localDebt.updatedAt.isAfter(cloudDebt.updatedAt)) {
            debtsUpdatedFromLocal++;
          }
        }
      }
    }

    for (final localDebt in localDebts) {
      if (!cloudDebtMap.containsKey(localDebt.id)) {
        mergedDebts.add(localDebt);
        debtsFromLocal++;
      }
    }

    // Merge Payments
    final localPaymentMap = {for (var p in localPayments) p.id: p};
    final cloudPaymentMap = {for (var p in cloudPayments) p.id: p};
    final mergedPayments = <Payment>[];

    for (final cloudPayment in cloudPayments) {
      final localPayment = localPaymentMap[cloudPayment.id];
      if (localPayment == null) {
        mergedPayments.add(cloudPayment);
        paymentsFromCloud++;
      } else {
        if (cloudPayment.updatedAt.isAfter(localPayment.updatedAt)) {
          mergedPayments.add(cloudPayment);
          paymentsUpdatedFromCloud++;
        } else {
          mergedPayments.add(localPayment);
          if (localPayment.updatedAt.isAfter(cloudPayment.updatedAt)) {
            paymentsUpdatedFromLocal++;
          }
        }
      }
    }

    for (final localPayment in localPayments) {
      if (!cloudPaymentMap.containsKey(localPayment.id)) {
        mergedPayments.add(localPayment);
        paymentsFromLocal++;
      }
    }

    // Validate referential integrity
    final validCustomerIds = mergedCustomers.map((c) => c.id).toSet();
    final validDebtIds = mergedDebts.map((d) => d.id).toSet();

    // Keep only debts that have valid customer references
    mergedDebts.removeWhere((d) => !validCustomerIds.contains(d.customerId));

    // Keep only payments that have valid debt references
    mergedPayments.removeWhere((p) => !validDebtIds.contains(p.loanId));

    return MergeResult(
      customers: mergedCustomers,
      debts: mergedDebts,
      payments: mergedPayments,
      stats: MergeStats(
        customersFromLocal: customersFromLocal,
        customersFromCloud: customersFromCloud,
        customersUpdatedFromCloud: customersUpdatedFromCloud,
        customersUpdatedFromLocal: customersUpdatedFromLocal,
        debtsFromLocal: debtsFromLocal,
        debtsFromCloud: debtsFromCloud,
        debtsUpdatedFromCloud: debtsUpdatedFromCloud,
        debtsUpdatedFromLocal: debtsUpdatedFromLocal,
        paymentsFromLocal: paymentsFromLocal,
        paymentsFromCloud: paymentsFromCloud,
        paymentsUpdatedFromCloud: paymentsUpdatedFromCloud,
        paymentsUpdatedFromLocal: paymentsUpdatedFromLocal,
      ),
    );
  }

  /// Generate a preview of what the merge would look like without applying it
  static MergeStats preview({
    required List<Customer> localCustomers,
    required List<Debt> localDebts,
    required List<Payment> localPayments,
    required List<Customer> cloudCustomers,
    required List<Debt> cloudDebts,
    required List<Payment> cloudPayments,
  }) {
    final result = merge(
      localCustomers: localCustomers,
      localDebts: localDebts,
      localPayments: localPayments,
      cloudCustomers: cloudCustomers,
      cloudDebts: cloudDebts,
      cloudPayments: cloudPayments,
    );
    return result.stats;
  }
}
