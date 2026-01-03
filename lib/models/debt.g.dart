// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 1;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      customerId: fields[1] as String,
      principal: fields[2] as double,
      startDate: fields[3] as DateTime,
      dueDate: fields[4] as DateTime,
      status: fields[5] as DebtStatus,
      notes: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      deletedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.principal)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtStatusAdapter extends TypeAdapter<DebtStatus> {
  @override
  final int typeId = 2;

  @override
  DebtStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtStatus.active;
      case 1:
        return DebtStatus.completed;
      default:
        return DebtStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, DebtStatus obj) {
    switch (obj) {
      case DebtStatus.active:
        writer.writeByte(0);
        break;
      case DebtStatus.completed:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
