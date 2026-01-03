import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/models/debt.dart';

void main() {
  group('Debt Model', () {
    late Debt debt;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      debt = Debt(
        id: 'debt-123',
        customerId: 'customer-456',
        principal: 100000.0,
        startDate: now,
        dueDate: now.add(const Duration(days: 30)),
        status: DebtStatus.active,
        notes: 'Test debt',
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Constructor', () {
      test('should create debt with required fields', () {
        final d = Debt(
          id: 'd1',
          customerId: 'c1',
          principal: 50000.0,
          startDate: now,
          dueDate: now.add(const Duration(days: 7)),
          createdAt: now,
          updatedAt: now,
        );

        expect(d.id, 'd1');
        expect(d.customerId, 'c1');
        expect(d.principal, 50000.0);
        expect(d.status, DebtStatus.active);
        expect(d.notes, '');
        expect(d.deletedAt, isNull);
      });

      test('should create debt with all fields', () {
        expect(debt.id, 'debt-123');
        expect(debt.customerId, 'customer-456');
        expect(debt.principal, 100000.0);
        expect(debt.notes, 'Test debt');
      });
    });

    group('totalAmount getter', () {
      test('should return principal as total amount', () {
        expect(debt.totalAmount, 100000.0);
      });

      test('should work with different principals', () {
        final d = Debt(
          id: 'd1',
          customerId: 'c1',
          principal: 250000.50,
          startDate: now,
          dueDate: now,
          createdAt: now,
          updatedAt: now,
        );

        expect(d.totalAmount, 250000.50);
      });
    });

    group('isDeleted getter', () {
      test('should return false when deletedAt is null', () {
        expect(debt.isDeleted, false);
      });

      test('should return true when deletedAt is set', () {
        final deletedDebt = Debt(
          id: 'd1',
          customerId: 'c1',
          principal: 1000.0,
          startDate: now,
          dueDate: now,
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        );

        expect(deletedDebt.isDeleted, true);
      });
    });

    group('DebtStatus enum', () {
      test('should have active status', () {
        expect(DebtStatus.active.name, 'active');
      });

      test('should have completed status', () {
        expect(DebtStatus.completed.name, 'completed');
      });
    });

    group('copyWith', () {
      test('should create copy with updated principal', () {
        final updated = debt.copyWith(principal: 200000.0);

        expect(updated.principal, 200000.0);
        expect(updated.id, debt.id);
        expect(updated.customerId, debt.customerId);
      });

      test('should create copy with updated status', () {
        final updated = debt.copyWith(status: DebtStatus.completed);

        expect(updated.status, DebtStatus.completed);
      });

      test('should set deletedAt when setDeletedAt is true', () {
        final deletedTime = DateTime.now();
        final deleted = debt.copyWith(
          deletedAt: deletedTime,
          setDeletedAt: true,
        );

        expect(deleted.deletedAt, deletedTime);
        expect(deleted.isDeleted, true);
      });
    });

    group('JSON Serialization', () {
      test('toJson should convert to valid map', () {
        final json = debt.toJson();

        expect(json['id'], 'debt-123');
        expect(json['customerId'], 'customer-456');
        expect(json['principal'], 100000.0);
        expect(json['status'], 'active');
        expect(json['notes'], 'Test debt');
        expect(json['startDate'], isA<String>());
        expect(json['dueDate'], isA<String>());
        expect(json.containsKey('deletedAt'), false);
      });

      test('toJson should include deletedAt when set', () {
        final deletedDebt = Debt(
          id: 'd1',
          customerId: 'c1',
          principal: 1000.0,
          startDate: now,
          dueDate: now,
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        );

        final json = deletedDebt.toJson();
        expect(json.containsKey('deletedAt'), true);
      });

      test('fromJson should parse valid JSON', () {
        final json = {
          'id': 'd1',
          'customerId': 'c1',
          'principal': 75000,
          'startDate': now.toIso8601String(),
          'dueDate': now.toIso8601String(),
          'status': 'active',
          'notes': 'From JSON',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Debt.fromJson(json);

        expect(parsed.id, 'd1');
        expect(parsed.principal, 75000.0);
        expect(parsed.status, DebtStatus.active);
      });

      test('fromJson should parse completed status', () {
        final json = {
          'id': 'd1',
          'customerId': 'c1',
          'principal': 1000,
          'startDate': now.toIso8601String(),
          'dueDate': now.toIso8601String(),
          'status': 'completed',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Debt.fromJson(json);
        expect(parsed.status, DebtStatus.completed);
      });

      test('fromJson should default to active for unknown status', () {
        final json = {
          'id': 'd1',
          'customerId': 'c1',
          'principal': 1000,
          'startDate': now.toIso8601String(),
          'dueDate': now.toIso8601String(),
          'status': 'unknown_status',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Debt.fromJson(json);
        expect(parsed.status, DebtStatus.active);
      });

      test('fromJson should handle integer principal', () {
        final json = {
          'id': 'd1',
          'customerId': 'c1',
          'principal': 50000, // int, not double
          'startDate': now.toIso8601String(),
          'dueDate': now.toIso8601String(),
          'status': 'active',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Debt.fromJson(json);
        expect(parsed.principal, 50000.0);
        expect(parsed.principal, isA<double>());
      });
    });

    group('List encode/decode', () {
      test('should encode list to JSON string', () {
        final debts = [debt];
        final encoded = Debt.encode(debts);

        expect(encoded, isA<String>());
        expect(encoded.contains('debt-123'), true);
      });

      test('should decode JSON string to list', () {
        final debts = [debt];
        final encoded = Debt.encode(debts);
        final decoded = Debt.decode(encoded);

        expect(decoded.length, 1);
        expect(decoded.first.id, 'debt-123');
        expect(decoded.first.principal, 100000.0);
      });

      test('should handle empty list', () {
        final encoded = Debt.encode([]);
        final decoded = Debt.decode(encoded);

        expect(decoded.isEmpty, true);
      });
    });
  });
}
