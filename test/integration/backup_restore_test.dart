import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/models/customer.dart';
import 'package:ahkyaway_mhat/models/debt.dart';
import 'package:ahkyaway_mhat/models/payment.dart';
import 'package:ahkyaway_mhat/services/backup_service.dart';
import '../mocks/mock_storage_service.dart';

void main() {
  group('Backup/Restore Integration', () {
    late MockStorageService mockStorage;
    late DateTime now;

    setUp(() {
      mockStorage = MockStorageService();
      now = DateTime(2026, 1, 1, 12, 0, 0);
    });

    group('BackupData round-trip', () {
      test('should preserve all data through backup and restore', () async {
        // Create original data
        final customers = [
          Customer(
            id: 'c1',
            name: 'John Doe',
            phone: '09123456789',
            address: '123 Main St',
            notes: 'VIP customer',
            createdAt: now,
            updatedAt: now,
          ),
          Customer(
            id: 'c2',
            name: 'Jane Smith',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final debts = [
          Debt(
            id: 'd1',
            customerId: 'c1',
            principal: 100000.0,
            startDate: now,
            dueDate: now.add(const Duration(days: 30)),
            status: DebtStatus.active,
            notes: 'First debt',
            createdAt: now,
            updatedAt: now,
          ),
          Debt(
            id: 'd2',
            customerId: 'c1',
            principal: 50000.0,
            startDate: now,
            dueDate: now.add(const Duration(days: 60)),
            status: DebtStatus.completed,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final payments = [
          Payment(
            id: 'p1',
            loanId: 'd1',
            amount: 25000.0,
            paymentDate: now,
            notes: 'First payment',
            createdAt: now,
          ),
          Payment(
            id: 'p2',
            loanId: 'd1',
            amount: 25000.0,
            paymentDate: now.add(const Duration(days: 7)),
            createdAt: now.add(const Duration(days: 7)),
          ),
        ];

        // Seed mock storage
        mockStorage.seedData(
          customers: customers,
          debts: debts,
          payments: payments,
        );

        // Create backup data (simulating export)
        final backupData = BackupData(
          customers: mockStorage.customers,
          debts: mockStorage.debts,
          payments: mockStorage.payments,
          exportedAt: DateTime.now(),
          appVersion: '2.0.9',
        );

        // Convert to JSON and back (simulating file write/read)
        final json = backupData.toJson();
        final restoredBackup = BackupData.fromJson(json);

        // Clear storage (simulating new device)
        mockStorage.clearAll();
        expect(mockStorage.customers.isEmpty, true);
        expect(mockStorage.debts.isEmpty, true);
        expect(mockStorage.payments.isEmpty, true);

        // Restore data
        await mockStorage.replaceAllData(
          customers: restoredBackup.customers,
          debts: restoredBackup.debts,
          payments: restoredBackup.payments,
        );

        // Verify all data is restored correctly
        expect(mockStorage.customers.length, 2);
        expect(mockStorage.debts.length, 2);
        expect(mockStorage.payments.length, 2);

        // Verify customer details
        final restoredC1 = mockStorage.getCustomerById('c1');
        expect(restoredC1, isNotNull);
        expect(restoredC1!.name, 'John Doe');
        expect(restoredC1.phone, '09123456789');
        expect(restoredC1.address, '123 Main St');
        expect(restoredC1.notes, 'VIP customer');

        // Verify debt details
        final restoredD1 = mockStorage.getDebtById('d1');
        expect(restoredD1, isNotNull);
        expect(restoredD1!.principal, 100000.0);
        expect(restoredD1.status, DebtStatus.active);

        final restoredD2 = mockStorage.getDebtById('d2');
        expect(restoredD2!.status, DebtStatus.completed);

        // Verify payment relationships
        final d1Payments = mockStorage.getPaymentsForDebt('d1');
        expect(d1Payments.length, 2);
        expect(mockStorage.getTotalPaidForDebt('d1'), 50000.0);
      });

      test('should handle empty data backup and restore', () async {
        // Create empty backup
        final backupData = BackupData(
          customers: [],
          debts: [],
          payments: [],
          exportedAt: DateTime.now(),
          appVersion: '2.0.9',
        );

        // Convert to JSON and back
        final json = backupData.toJson();
        final restoredBackup = BackupData.fromJson(json);

        // Restore to storage
        await mockStorage.replaceAllData(
          customers: restoredBackup.customers,
          debts: restoredBackup.debts,
          payments: restoredBackup.payments,
        );

        // Verify empty
        expect(mockStorage.customers.isEmpty, true);
        expect(mockStorage.debts.isEmpty, true);
        expect(mockStorage.payments.isEmpty, true);
      });

      test('should preserve soft-deleted items', () async {
        final deletedCustomer = Customer(
          id: 'c-deleted',
          name: 'Deleted User',
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        );

        final backupData = BackupData(
          customers: [deletedCustomer],
          debts: [],
          payments: [],
          exportedAt: DateTime.now(),
          appVersion: '2.0.9',
        );

        // Round-trip
        final json = backupData.toJson();
        final restoredBackup = BackupData.fromJson(json);

        // Verify deletedAt is preserved
        expect(restoredBackup.customers.first.isDeleted, true);
        expect(restoredBackup.customers.first.deletedAt, now);
      });
    });

    group('MockStorageService operations', () {
      test('should add and retrieve customer', () async {
        final customer = Customer(
          id: 'c1',
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        await mockStorage.addCustomer(customer);

        expect(mockStorage.customers.length, 1);
        expect(mockStorage.getCustomerById('c1'), isNotNull);
      });

      test('should add debt and calculate totals', () async {
        await mockStorage.addCustomer(
          Customer(id: 'c1', name: 'Test', createdAt: now, updatedAt: now),
        );

        await mockStorage.addDebt(
          Debt(
            id: 'd1',
            customerId: 'c1',
            principal: 100000.0,
            startDate: now,
            dueDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        expect(mockStorage.activeDebtsCount, 1);
        expect(mockStorage.totalOutstandingDebts, 100000.0);
      });

      test('should track payments and remaining balance', () async {
        await mockStorage.addCustomer(
          Customer(id: 'c1', name: 'Test', createdAt: now, updatedAt: now),
        );

        await mockStorage.addDebt(
          Debt(
            id: 'd1',
            customerId: 'c1',
            principal: 100000.0,
            startDate: now,
            dueDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await mockStorage.addPayment(
          Payment(
            id: 'p1',
            loanId: 'd1',
            amount: 40000.0,
            paymentDate: now,
            createdAt: now,
          ),
        );

        expect(mockStorage.getTotalPaidForDebt('d1'), 40000.0);
        expect(mockStorage.totalOutstandingDebts, 60000.0);
      });

      test('should delete customer and cascade to debts', () async {
        await mockStorage.addCustomer(
          Customer(id: 'c1', name: 'Test', createdAt: now, updatedAt: now),
        );

        await mockStorage.addDebt(
          Debt(
            id: 'd1',
            customerId: 'c1',
            principal: 50000.0,
            startDate: now,
            dueDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        expect(mockStorage.customers.length, 1);
        expect(mockStorage.debts.length, 1);

        await mockStorage.deleteCustomer('c1');

        expect(mockStorage.customers.length, 0);
        expect(mockStorage.debts.length, 0);
      });
    });
  });
}
