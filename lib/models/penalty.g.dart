// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PenaltyRuleAdapter extends TypeAdapter<PenaltyRule> {
  @override
  final int typeId = 16;

  @override
  PenaltyRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PenaltyRule(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as PenaltyType,
      calculationType: fields[4] as PenaltyCalculationType,
      baseAmount: fields[5] as double,
      percentage: fields[6] as double?,
      gracePeriodDays: fields[7] as int?,
      maxAmount: fields[8] as double?,
      minAmount: fields[9] as double?,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime?,
      createdBy: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PenaltyRule obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.calculationType)
      ..writeByte(5)
      ..write(obj.baseAmount)
      ..writeByte(6)
      ..write(obj.percentage)
      ..writeByte(7)
      ..write(obj.gracePeriodDays)
      ..writeByte(8)
      ..write(obj.maxAmount)
      ..writeByte(9)
      ..write(obj.minAmount)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PenaltyAdapter extends TypeAdapter<Penalty> {
  @override
  final int typeId = 12;

  @override
  Penalty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Penalty(
      id: fields[0] as String,
      memberId: fields[1] as String,
      ruleId: fields[2] as String,
      type: fields[3] as PenaltyType,
      title: fields[4] as String,
      description: fields[5] as String,
      amount: fields[6] as double,
      paidAmount: fields[7] as double,
      status: fields[8] as PenaltyStatus,
      appliedDate: fields[9] as DateTime,
      dueDate: fields[10] as DateTime?,
      paidDate: fields[11] as DateTime?,
      waivedDate: fields[12] as DateTime?,
      waivedBy: fields[13] as String?,
      waivedReason: fields[14] as String?,
      relatedEntityId: fields[15] as String?,
      relatedEntityType: fields[16] as String?,
      notes: fields[17] as String?,
      appliedBy: fields[18] as String?,
      paymentTransactionIds: (fields[19] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Penalty obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.ruleId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.paidAmount)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.appliedDate)
      ..writeByte(10)
      ..write(obj.dueDate)
      ..writeByte(11)
      ..write(obj.paidDate)
      ..writeByte(12)
      ..write(obj.waivedDate)
      ..writeByte(13)
      ..write(obj.waivedBy)
      ..writeByte(14)
      ..write(obj.waivedReason)
      ..writeByte(15)
      ..write(obj.relatedEntityId)
      ..writeByte(16)
      ..write(obj.relatedEntityType)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.appliedBy)
      ..writeByte(19)
      ..write(obj.paymentTransactionIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PenaltyTypeAdapter extends TypeAdapter<PenaltyType> {
  @override
  final int typeId = 13;

  @override
  PenaltyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PenaltyType.lateFee;
      case 1:
        return PenaltyType.missedContribution;
      case 2:
        return PenaltyType.loanDefault;
      case 3:
        return PenaltyType.meetingAbsence;
      case 4:
        return PenaltyType.ruleViolation;
      case 5:
        return PenaltyType.custom;
      default:
        return PenaltyType.lateFee;
    }
  }

  @override
  void write(BinaryWriter writer, PenaltyType obj) {
    switch (obj) {
      case PenaltyType.lateFee:
        writer.writeByte(0);
        break;
      case PenaltyType.missedContribution:
        writer.writeByte(1);
        break;
      case PenaltyType.loanDefault:
        writer.writeByte(2);
        break;
      case PenaltyType.meetingAbsence:
        writer.writeByte(3);
        break;
      case PenaltyType.ruleViolation:
        writer.writeByte(4);
        break;
      case PenaltyType.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PenaltyStatusAdapter extends TypeAdapter<PenaltyStatus> {
  @override
  final int typeId = 14;

  @override
  PenaltyStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PenaltyStatus.pending;
      case 1:
        return PenaltyStatus.active;
      case 2:
        return PenaltyStatus.paid;
      case 3:
        return PenaltyStatus.waived;
      case 4:
        return PenaltyStatus.cancelled;
      default:
        return PenaltyStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PenaltyStatus obj) {
    switch (obj) {
      case PenaltyStatus.pending:
        writer.writeByte(0);
        break;
      case PenaltyStatus.active:
        writer.writeByte(1);
        break;
      case PenaltyStatus.paid:
        writer.writeByte(2);
        break;
      case PenaltyStatus.waived:
        writer.writeByte(3);
        break;
      case PenaltyStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PenaltyCalculationTypeAdapter
    extends TypeAdapter<PenaltyCalculationType> {
  @override
  final int typeId = 15;

  @override
  PenaltyCalculationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PenaltyCalculationType.fixedAmount;
      case 1:
        return PenaltyCalculationType.percentage;
      case 2:
        return PenaltyCalculationType.dailyRate;
      case 3:
        return PenaltyCalculationType.tiered;
      default:
        return PenaltyCalculationType.fixedAmount;
    }
  }

  @override
  void write(BinaryWriter writer, PenaltyCalculationType obj) {
    switch (obj) {
      case PenaltyCalculationType.fixedAmount:
        writer.writeByte(0);
        break;
      case PenaltyCalculationType.percentage:
        writer.writeByte(1);
        break;
      case PenaltyCalculationType.dailyRate:
        writer.writeByte(2);
        break;
      case PenaltyCalculationType.tiered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyCalculationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
