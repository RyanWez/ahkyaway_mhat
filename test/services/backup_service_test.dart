import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/models/customer.dart';
import 'package:ahkyaway_mhat/models/debt.dart';
import 'package:ahkyaway_mhat/models/payment.dart';
import 'package:ahkyaway_mhat/services/backup_service.dart';

void main() {
  group('BackupData', () {
    late DateTime now;
    late List<Customer> customers;
    late List<Debt> debts;
    late List<Payment> payments;
    late BackupData backupData;

    setUp(() {
      now = DateTime(2026, 1, 1, 12, 0, 0);

      customers = [
        Customer(
          id: 'c1',
          name: 'Test Customer',
          phone: '09123456789',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      debts = [
        Debt(
          id: 'd1',
          customerId: 'c1',
          principal: 100000.0,
          startDate: now,
          dueDate: now.add(const Duration(days: 30)),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      payments = [
        Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 50000.0,
          paymentDate: now,
          createdAt: now,
        ),
      ];

      backupData = BackupData(
        customers: customers,
        debts: debts,
        payments: payments,
        exportedAt: now,
        appVersion: '2.0.9',
      );
    });

    group('Constructor', () {
      test('should create BackupData with all fields', () {
        expect(backupData.customers.length, 1);
        expect(backupData.debts.length, 1);
        expect(backupData.payments.length, 1);
        expect(backupData.exportedAt, now);
        expect(backupData.appVersion, '2.0.9');
      });

      test('should create BackupData with empty lists', () {
        final emptyBackup = BackupData(
          customers: [],
          debts: [],
          payments: [],
          exportedAt: now,
          appVersion: '1.0.0',
        );

        expect(emptyBackup.customers.isEmpty, true);
        expect(emptyBackup.debts.isEmpty, true);
        expect(emptyBackup.payments.isEmpty, true);
      });
    });

    group('toJson', () {
      test('should convert to valid JSON map', () {
        final json = backupData.toJson();

        expect(json['appVersion'], '2.0.9');
        expect(json['exportedAt'], now.toIso8601String());
        expect(json['customers'], isA<List>());
        expect(json['debts'], isA<List>());
        expect(json['payments'], isA<List>());
      });

      test('should include all customers in JSON', () {
        final json = backupData.toJson();
        final customersJson = json['customers'] as List;

        expect(customersJson.length, 1);
        expect(customersJson.first['id'], 'c1');
        expect(customersJson.first['name'], 'Test Customer');
      });

      test('should include all debts in JSON', () {
        final json = backupData.toJson();
        final debtsJson = json['debts'] as List;

        expect(debtsJson.length, 1);
        expect(debtsJson.first['id'], 'd1');
        expect(debtsJson.first['principal'], 100000.0);
      });

      test('should include all payments in JSON', () {
        final json = backupData.toJson();
        final paymentsJson = json['payments'] as List;

        expect(paymentsJson.length, 1);
        expect(paymentsJson.first['id'], 'p1');
        expect(paymentsJson.first['amount'], 50000.0);
      });

      test('should handle empty collections', () {
        final emptyBackup = BackupData(
          customers: [],
          debts: [],
          payments: [],
          exportedAt: now,
          appVersion: '1.0.0',
        );

        final json = emptyBackup.toJson();

        expect((json['customers'] as List).isEmpty, true);
        expect((json['debts'] as List).isEmpty, true);
        expect((json['payments'] as List).isEmpty, true);
      });
    });

    group('fromJson', () {
      test('should parse valid JSON', () {
        final json = backupData.toJson();
        final parsed = BackupData.fromJson(json);

        expect(parsed.appVersion, '2.0.9');
        expect(parsed.exportedAt, now);
        expect(parsed.customers.length, 1);
        expect(parsed.debts.length, 1);
        expect(parsed.payments.length, 1);
      });

      test('should parse customers correctly', () {
        final json = backupData.toJson();
        final parsed = BackupData.fromJson(json);

        expect(parsed.customers.first.id, 'c1');
        expect(parsed.customers.first.name, 'Test Customer');
        expect(parsed.customers.first.phone, '09123456789');
      });

      test('should parse debts correctly', () {
        final json = backupData.toJson();
        final parsed = BackupData.fromJson(json);

        expect(parsed.debts.first.id, 'd1');
        expect(parsed.debts.first.customerId, 'c1');
        expect(parsed.debts.first.principal, 100000.0);
      });

      test('should parse payments correctly', () {
        final json = backupData.toJson();
        final parsed = BackupData.fromJson(json);

        expect(parsed.payments.first.id, 'p1');
        expect(parsed.payments.first.loanId, 'd1');
        expect(parsed.payments.first.amount, 50000.0);
      });

      test('should handle missing appVersion', () {
        final json = {
          'exportedAt': now.toIso8601String(),
          'customers': [],
          'debts': [],
          'payments': [],
        };

        final parsed = BackupData.fromJson(json);
        expect(parsed.appVersion, 'unknown');
      });

      test('should handle empty collections', () {
        final json = {
          'appVersion': '1.0.0',
          'exportedAt': now.toIso8601String(),
          'customers': [],
          'debts': [],
          'payments': [],
        };

        final parsed = BackupData.fromJson(json);

        expect(parsed.customers.isEmpty, true);
        expect(parsed.debts.isEmpty, true);
        expect(parsed.payments.isEmpty, true);
      });
    });

    group('Round-trip serialization', () {
      test('should preserve data through toJson and fromJson', () {
        // Create complex backup data
        final multiCustomerBackup = BackupData(
          customers: [
            Customer(
              id: 'c1',
              name: 'Customer 1',
              createdAt: now,
              updatedAt: now,
            ),
            Customer(
              id: 'c2',
              name: 'Customer 2',
              phone: '123',
              address: 'Addr',
              createdAt: now,
              updatedAt: now,
            ),
          ],
          debts: [
            Debt(
              id: 'd1',
              customerId: 'c1',
              principal: 50000,
              startDate: now,
              dueDate: now,
              createdAt: now,
              updatedAt: now,
            ),
            Debt(
              id: 'd2',
              customerId: 'c2',
              principal: 75000,
              startDate: now,
              dueDate: now,
              status: DebtStatus.completed,
              createdAt: now,
              updatedAt: now,
            ),
          ],
          payments: [
            Payment(
              id: 'p1',
              loanId: 'd1',
              amount: 25000,
              paymentDate: now,
              createdAt: now,
            ),
          ],
          exportedAt: now,
          appVersion: '2.0.9',
        );

        // Convert to JSON and back
        final json = multiCustomerBackup.toJson();
        final restored = BackupData.fromJson(json);

        // Verify
        expect(restored.customers.length, 2);
        expect(restored.debts.length, 2);
        expect(restored.payments.length, 1);
        expect(restored.debts[1].status, DebtStatus.completed);
        expect(restored.appVersion, '2.0.9');
      });
    });
  });

  group('BackupFile', () {
    test('should create BackupFile with default isAutoBackup false', () {
      final backupFile = BackupFile(
        filename: 'test.json',
        path: '/path/to/test.json',
        createdAt: DateTime.now(),
        sizeBytes: 1000,
      );

      expect(backupFile.isAutoBackup, false);
    });

    test('should create BackupFile with isAutoBackup true', () {
      final backupFile = BackupFile(
        filename: 'auto-backup_test.json',
        path: '/path/to/auto-backup_test.json',
        createdAt: DateTime.now(),
        sizeBytes: 1000,
        isAutoBackup: true,
      );

      expect(backupFile.isAutoBackup, true);
    });

    group('formattedSize', () {
      test('should format bytes', () {
        final backupFile = BackupFile(
          filename: 'test.json',
          path: '/path',
          createdAt: DateTime.now(),
          sizeBytes: 500,
        );

        expect(backupFile.formattedSize, '500 B');
      });

      test('should format kilobytes', () {
        final backupFile = BackupFile(
          filename: 'test.json',
          path: '/path',
          createdAt: DateTime.now(),
          sizeBytes: 2048, // 2 KB
        );

        expect(backupFile.formattedSize, '2.0 KB');
      });

      test('should format megabytes', () {
        final backupFile = BackupFile(
          filename: 'test.json',
          path: '/path',
          createdAt: DateTime.now(),
          sizeBytes: 1048576, // 1 MB
        );

        expect(backupFile.formattedSize, '1.0 MB');
      });

      test('should format 1.5 MB', () {
        final backupFile = BackupFile(
          filename: 'test.json',
          path: '/path',
          createdAt: DateTime.now(),
          sizeBytes: 1572864, // 1.5 MB
        );

        expect(backupFile.formattedSize, '1.5 MB');
      });
    });
  });
}
