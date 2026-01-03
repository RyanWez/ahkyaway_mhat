import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/models/payment.dart';

void main() {
  group('Payment Model', () {
    late Payment payment;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      payment = Payment(
        id: 'payment-123',
        loanId: 'debt-456',
        amount: 50000.0,
        paymentDate: now,
        notes: 'First payment',
        createdAt: now,
      );
    });

    group('Constructor', () {
      test('should create payment with required fields', () {
        final p = Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 10000.0,
          paymentDate: now,
          createdAt: now,
        );

        expect(p.id, 'p1');
        expect(p.loanId, 'd1');
        expect(p.amount, 10000.0);
        expect(p.notes, '');
        expect(p.deletedAt, isNull);
      });

      test('should set updatedAt to createdAt when not provided', () {
        final p = Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 10000.0,
          paymentDate: now,
          createdAt: now,
        );

        expect(p.updatedAt, p.createdAt);
      });

      test('should use provided updatedAt', () {
        final updateTime = now.add(const Duration(hours: 1));
        final p = Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 10000.0,
          paymentDate: now,
          createdAt: now,
          updatedAt: updateTime,
        );

        expect(p.updatedAt, updateTime);
        expect(p.updatedAt.isAfter(p.createdAt), true);
      });
    });

    group('isDeleted getter', () {
      test('should return false when deletedAt is null', () {
        expect(payment.isDeleted, false);
      });

      test('should return true when deletedAt is set', () {
        final deletedPayment = Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 1000.0,
          paymentDate: now,
          createdAt: now,
          deletedAt: now,
        );

        expect(deletedPayment.isDeleted, true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated amount', () {
        final updated = payment.copyWith(amount: 75000.0);

        expect(updated.amount, 75000.0);
        expect(updated.id, payment.id);
        expect(updated.loanId, payment.loanId);
      });

      test('should create copy with updated notes', () {
        final updated = payment.copyWith(notes: 'Updated notes');

        expect(updated.notes, 'Updated notes');
      });

      test('should set deletedAt when setDeletedAt is true', () {
        final deletedTime = DateTime.now();
        final deleted = payment.copyWith(
          deletedAt: deletedTime,
          setDeletedAt: true,
        );

        expect(deleted.deletedAt, deletedTime);
        expect(deleted.isDeleted, true);
      });

      test('should not change deletedAt when setDeletedAt is false', () {
        final deleted = payment.copyWith(
          deletedAt: DateTime.now(),
          setDeletedAt: false,
        );

        expect(deleted.deletedAt, isNull);
      });
    });

    group('JSON Serialization', () {
      test('toJson should convert to valid map', () {
        final json = payment.toJson();

        expect(json['id'], 'payment-123');
        expect(json['loanId'], 'debt-456');
        expect(json['amount'], 50000.0);
        expect(json['notes'], 'First payment');
        expect(json['paymentDate'], isA<String>());
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
        expect(json.containsKey('deletedAt'), false);
      });

      test('toJson should include deletedAt when set', () {
        final deletedPayment = Payment(
          id: 'p1',
          loanId: 'd1',
          amount: 1000.0,
          paymentDate: now,
          createdAt: now,
          deletedAt: now,
        );

        final json = deletedPayment.toJson();
        expect(json.containsKey('deletedAt'), true);
      });

      test('fromJson should parse valid JSON', () {
        final json = {
          'id': 'p1',
          'loanId': 'd1',
          'amount': 25000,
          'paymentDate': now.toIso8601String(),
          'notes': 'From JSON',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Payment.fromJson(json);

        expect(parsed.id, 'p1');
        expect(parsed.loanId, 'd1');
        expect(parsed.amount, 25000.0);
        expect(parsed.notes, 'From JSON');
      });

      test('fromJson should handle null optional fields', () {
        final json = {
          'id': 'p1',
          'loanId': 'd1',
          'amount': 1000,
          'paymentDate': now.toIso8601String(),
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Payment.fromJson(json);

        expect(parsed.notes, '');
        expect(parsed.deletedAt, isNull);
      });

      test(
        'fromJson should fallback to createdAt when updatedAt is missing (backward compatibility)',
        () {
          final json = {
            'id': 'p1',
            'loanId': 'd1',
            'amount': 1000,
            'paymentDate': now.toIso8601String(),
            'createdAt': now.toIso8601String(),
            // No updatedAt - simulating old data format
          };

          final parsed = Payment.fromJson(json);

          expect(parsed.updatedAt, parsed.createdAt);
        },
      );

      test('fromJson should handle integer amount', () {
        final json = {
          'id': 'p1',
          'loanId': 'd1',
          'amount': 15000, // int, not double
          'paymentDate': now.toIso8601String(),
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Payment.fromJson(json);
        expect(parsed.amount, 15000.0);
        expect(parsed.amount, isA<double>());
      });
    });

    group('List encode/decode', () {
      test('should encode list to JSON string', () {
        final payments = [payment];
        final encoded = Payment.encode(payments);

        expect(encoded, isA<String>());
        expect(encoded.contains('payment-123'), true);
      });

      test('should decode JSON string to list', () {
        final payments = [payment];
        final encoded = Payment.encode(payments);
        final decoded = Payment.decode(encoded);

        expect(decoded.length, 1);
        expect(decoded.first.id, 'payment-123');
        expect(decoded.first.amount, 50000.0);
      });

      test('should handle empty list', () {
        final encoded = Payment.encode([]);
        final decoded = Payment.decode(encoded);

        expect(decoded.isEmpty, true);
      });

      test('should handle multiple payments', () {
        final payments = [
          payment,
          Payment(
            id: 'p2',
            loanId: 'debt-456',
            amount: 25000.0,
            paymentDate: now,
            createdAt: now,
          ),
        ];

        final encoded = Payment.encode(payments);
        final decoded = Payment.decode(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].amount, 50000.0);
        expect(decoded[1].amount, 25000.0);
      });
    });
  });
}
