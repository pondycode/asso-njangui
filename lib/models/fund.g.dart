// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FundAdapter extends TypeAdapter<Fund> {
  @override
  final int typeId = 3;

  @override
  Fund read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fund(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as FundType,
      balance: fields[4] as double,
      targetAmount: fields[5] as double,
      interestRate: fields[6] as double,
      createdDate: fields[7] as DateTime,
      lastUpdated: fields[8] as DateTime,
      isActive: fields[9] as bool,
      managerId: fields[10] as String?,
      minimumContribution: fields[11] as double,
      maximumContribution: fields[12] as double,
      contributionFrequencyDays: fields[13] as int,
      memberBalances: (fields[14] as Map).cast<String, double>(),
      settings: (fields[15] as Map).cast<String, dynamic>(),
      allowedMembers: (fields[16] as List).cast<String>(),
      totalContributions: fields[17] as double,
      totalWithdrawals: fields[18] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Fund obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.balance)
      ..writeByte(5)
      ..write(obj.targetAmount)
      ..writeByte(6)
      ..write(obj.interestRate)
      ..writeByte(7)
      ..write(obj.createdDate)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.managerId)
      ..writeByte(11)
      ..write(obj.minimumContribution)
      ..writeByte(12)
      ..write(obj.maximumContribution)
      ..writeByte(13)
      ..write(obj.contributionFrequencyDays)
      ..writeByte(14)
      ..write(obj.memberBalances)
      ..writeByte(15)
      ..write(obj.settings)
      ..writeByte(16)
      ..write(obj.allowedMembers)
      ..writeByte(17)
      ..write(obj.totalContributions)
      ..writeByte(18)
      ..write(obj.totalWithdrawals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FundTypeAdapter extends TypeAdapter<FundType> {
  @override
  final int typeId = 2;

  @override
  FundType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FundType.savings;
      case 1:
        return FundType.investment;
      case 2:
        return FundType.emergency;
      case 3:
        return FundType.loan;
      default:
        return FundType.savings;
    }
  }

  @override
  void write(BinaryWriter writer, FundType obj) {
    switch (obj) {
      case FundType.savings:
        writer.writeByte(0);
        break;
      case FundType.investment:
        writer.writeByte(1);
        break;
      case FundType.emergency:
        writer.writeByte(2);
        break;
      case FundType.loan:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
