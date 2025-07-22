// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 5;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      memberId: fields[1] as String,
      fundId: fields[2] as String?,
      loanId: fields[3] as String?,
      type: fields[4] as TransactionType,
      amount: fields[5] as double,
      date: fields[6] as DateTime,
      description: fields[7] as String,
      reference: fields[8] as String?,
      approvedBy: fields[9] as String?,
      approvalDate: fields[10] as DateTime?,
      isReversed: fields[11] as bool,
      reversalReason: fields[12] as String?,
      reversalDate: fields[13] as DateTime?,
      reversedBy: fields[14] as String?,
      metadata: (fields[15] as Map).cast<String, dynamic>(),
      balanceBefore: fields[16] as double,
      balanceAfter: fields[17] as double,
      receiptNumber: fields[18] as String?,
      attachments: (fields[19] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.fundId)
      ..writeByte(3)
      ..write(obj.loanId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.reference)
      ..writeByte(9)
      ..write(obj.approvedBy)
      ..writeByte(10)
      ..write(obj.approvalDate)
      ..writeByte(11)
      ..write(obj.isReversed)
      ..writeByte(12)
      ..write(obj.reversalReason)
      ..writeByte(13)
      ..write(obj.reversalDate)
      ..writeByte(14)
      ..write(obj.reversedBy)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.balanceBefore)
      ..writeByte(17)
      ..write(obj.balanceAfter)
      ..writeByte(18)
      ..write(obj.receiptNumber)
      ..writeByte(19)
      ..write(obj.attachments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 4;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.contribution;
      case 1:
        return TransactionType.withdrawal;
      case 2:
        return TransactionType.loanDisbursement;
      case 3:
        return TransactionType.loanRepayment;
      case 4:
        return TransactionType.interestPayment;
      case 5:
        return TransactionType.fee;
      case 6:
        return TransactionType.transfer;
      case 7:
        return TransactionType.adjustment;
      default:
        return TransactionType.contribution;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.contribution:
        writer.writeByte(0);
        break;
      case TransactionType.withdrawal:
        writer.writeByte(1);
        break;
      case TransactionType.loanDisbursement:
        writer.writeByte(2);
        break;
      case TransactionType.loanRepayment:
        writer.writeByte(3);
        break;
      case TransactionType.interestPayment:
        writer.writeByte(4);
        break;
      case TransactionType.fee:
        writer.writeByte(5);
        break;
      case TransactionType.transfer:
        writer.writeByte(6);
        break;
      case TransactionType.adjustment:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
