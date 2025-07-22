// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanSettingsAdapter extends TypeAdapter<LoanSettings> {
  @override
  final int typeId = 9;

  @override
  LoanSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanSettings(
      defaultMonthlyInterestRate: fields[0] as double,
      minimumInterestRate: fields[1] as double,
      maximumInterestRate: fields[2] as double,
      allowCustomRates: fields[3] as bool,
      minimumLoanTermMonths: fields[4] as int,
      maximumLoanTermMonths: fields[5] as int,
      maxLoanToContributionRatio: fields[6] as double,
      minimumContributionMonths: fields[7] as int,
      lastUpdated: fields[8] as DateTime,
      updatedBy: fields[9] as String,
      metadata: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LoanSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.defaultMonthlyInterestRate)
      ..writeByte(1)
      ..write(obj.minimumInterestRate)
      ..writeByte(2)
      ..write(obj.maximumInterestRate)
      ..writeByte(3)
      ..write(obj.allowCustomRates)
      ..writeByte(4)
      ..write(obj.minimumLoanTermMonths)
      ..writeByte(5)
      ..write(obj.maximumLoanTermMonths)
      ..writeByte(6)
      ..write(obj.maxLoanToContributionRatio)
      ..writeByte(7)
      ..write(obj.minimumContributionMonths)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.updatedBy)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
