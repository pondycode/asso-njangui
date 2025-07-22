// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FundContributionAdapter extends TypeAdapter<FundContribution> {
  @override
  final int typeId = 9;

  @override
  FundContribution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FundContribution(
      fundId: fields[0] as String,
      fundName: fields[1] as String,
      amount: fields[2] as double,
      previousBalance: fields[3] as double,
      newBalance: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FundContribution obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fundId)
      ..writeByte(1)
      ..write(obj.fundName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.previousBalance)
      ..writeByte(4)
      ..write(obj.newBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundContributionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContributionAdapter extends TypeAdapter<Contribution> {
  @override
  final int typeId = 10;

  @override
  Contribution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contribution(
      id: fields[0] as String,
      memberId: fields[1] as String,
      date: fields[2] as DateTime,
      fundContributions: (fields[3] as List).cast<FundContribution>(),
      totalAmount: fields[4] as double,
      notes: fields[5] as String?,
      receiptNumber: fields[6] as String?,
      processedBy: fields[7] as String?,
      processedDate: fields[8] as DateTime?,
      isProcessed: fields[9] as bool,
      paymentMethod: fields[10] as String?,
      reference: fields[11] as String?,
      metadata: (fields[12] as Map).cast<String, dynamic>(),
      transactionIds: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Contribution obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.fundContributions)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.receiptNumber)
      ..writeByte(7)
      ..write(obj.processedBy)
      ..writeByte(8)
      ..write(obj.processedDate)
      ..writeByte(9)
      ..write(obj.isProcessed)
      ..writeByte(10)
      ..write(obj.paymentMethod)
      ..writeByte(11)
      ..write(obj.reference)
      ..writeByte(12)
      ..write(obj.metadata)
      ..writeByte(13)
      ..write(obj.transactionIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
