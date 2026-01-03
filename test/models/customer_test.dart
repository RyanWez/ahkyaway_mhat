import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/models/customer.dart';

void main() {
  group('Customer Model', () {
    late Customer customer;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      customer = Customer(
        id: 'customer-123',
        name: 'John Doe',
        phone: '09123456789',
        address: '123 Main St',
        notes: 'Test notes',
        createdAt: now,
        updatedAt: now,
      );
    });

    group('Constructor', () {
      test('should create customer with required fields', () {
        final c = Customer(
          id: 'c1',
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        expect(c.id, 'c1');
        expect(c.name, 'Test');
        expect(c.phone, '');
        expect(c.address, '');
        expect(c.notes, '');
        expect(c.deletedAt, isNull);
      });

      test('should create customer with all fields', () {
        expect(customer.id, 'customer-123');
        expect(customer.name, 'John Doe');
        expect(customer.phone, '09123456789');
        expect(customer.address, '123 Main St');
        expect(customer.notes, 'Test notes');
      });
    });

    group('isDeleted getter', () {
      test('should return false when deletedAt is null', () {
        expect(customer.isDeleted, false);
      });

      test('should return true when deletedAt is set', () {
        final deletedCustomer = Customer(
          id: 'c1',
          name: 'Deleted User',
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        );

        expect(deletedCustomer.isDeleted, true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated name', () {
        final updated = customer.copyWith(name: 'Jane Doe');

        expect(updated.name, 'Jane Doe');
        expect(updated.id, customer.id);
        expect(updated.phone, customer.phone);
      });

      test('should create copy with multiple updated fields', () {
        final updated = customer.copyWith(
          name: 'New Name',
          phone: '09999999999',
          address: 'New Address',
        );

        expect(updated.name, 'New Name');
        expect(updated.phone, '09999999999');
        expect(updated.address, 'New Address');
        expect(updated.notes, customer.notes);
      });

      test('should set deletedAt when setDeletedAt is true', () {
        final deletedTime = DateTime.now();
        final deleted = customer.copyWith(
          deletedAt: deletedTime,
          setDeletedAt: true,
        );

        expect(deleted.deletedAt, deletedTime);
        expect(deleted.isDeleted, true);
      });

      test('should not change deletedAt when setDeletedAt is false', () {
        final deleted = customer.copyWith(
          deletedAt: DateTime.now(),
          setDeletedAt: false,
        );

        expect(deleted.deletedAt, isNull);
      });
    });

    group('JSON Serialization', () {
      test('toJson should convert to valid map', () {
        final json = customer.toJson();

        expect(json['id'], 'customer-123');
        expect(json['name'], 'John Doe');
        expect(json['phone'], '09123456789');
        expect(json['address'], '123 Main St');
        expect(json['notes'], 'Test notes');
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
        expect(json.containsKey('deletedAt'), false);
      });

      test('toJson should include deletedAt when set', () {
        final deletedCustomer = Customer(
          id: 'c1',
          name: 'Deleted',
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
        );

        final json = deletedCustomer.toJson();
        expect(json.containsKey('deletedAt'), true);
      });

      test('fromJson should parse valid JSON', () {
        final json = {
          'id': 'c1',
          'name': 'From JSON',
          'phone': '123',
          'address': 'Addr',
          'notes': 'Notes',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Customer.fromJson(json);

        expect(parsed.id, 'c1');
        expect(parsed.name, 'From JSON');
        expect(parsed.phone, '123');
        expect(parsed.isDeleted, false);
      });

      test('fromJson should handle null optional fields', () {
        final json = {
          'id': 'c1',
          'name': 'Minimal',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final parsed = Customer.fromJson(json);

        expect(parsed.phone, '');
        expect(parsed.address, '');
        expect(parsed.notes, '');
      });

      test('fromJson should parse deletedAt', () {
        final json = {
          'id': 'c1',
          'name': 'Deleted',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'deletedAt': now.toIso8601String(),
        };

        final parsed = Customer.fromJson(json);
        expect(parsed.isDeleted, true);
      });
    });

    group('List encode/decode', () {
      test('should encode list to JSON string', () {
        final customers = [customer];
        final encoded = Customer.encode(customers);

        expect(encoded, isA<String>());
        expect(encoded.contains('customer-123'), true);
      });

      test('should decode JSON string to list', () {
        final customers = [customer];
        final encoded = Customer.encode(customers);
        final decoded = Customer.decode(encoded);

        expect(decoded.length, 1);
        expect(decoded.first.id, 'customer-123');
        expect(decoded.first.name, 'John Doe');
      });

      test('should handle empty list', () {
        final encoded = Customer.encode([]);
        final decoded = Customer.decode(encoded);

        expect(decoded.isEmpty, true);
      });

      test('should handle multiple customers', () {
        final customers = [
          customer,
          Customer(
            id: 'c2',
            name: 'Second Customer',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final encoded = Customer.encode(customers);
        final decoded = Customer.decode(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].id, 'customer-123');
        expect(decoded[1].id, 'c2');
      });
    });
  });
}
