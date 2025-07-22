// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanRepaymentAdapter extends TypeAdapter<LoanRepayment> {
  @override
  final int typeId = 7;

  @override
  LoanRepayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanRepayment(
      id: fields[0] as String,
      amount: fields[1] as double,
      principalAmount: fields[2] as double,
      interestAmount: fields[3] as double,
      dueDate: fields[4] as DateTime,
      paidDate: fields[5] as DateTime?,
      isPaid: fields[6] as bool,
      transactionId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanRepayment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.principalAmount)
      ..writeByte(3)
      ..write(obj.interestAmount)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.paidDate)
      ..writeByte(6)
      ..write(obj.isPaid)
      ..writeByte(7)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanRepaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 8;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
      id: fields[0] as String,
      memberId: fields[1] as String,
      principalAmount: fields[2] as double,
      interestRate: fields[3] as double,
      termInMonths: fields[4] as int,
      applicationDate: fields[5] as DateTime,
      approvalDate: fields[6] as DateTime?,
      disbursementDate: fields[7] as DateTime?,
      status: fields[8] as LoanStatus,
      purpose: fields[9] as String,
      approvedBy: fields[10] as String?,
      disbursedBy: fields[11] as String?,
      paidAmount: fields[12] as double,
      outstandingAmount: fields[13] as double,
      repayments: (fields[14] as List).cast<LoanRepayment>(),
      metadata: (fields[15] as Map).cast<String, dynamic>(),
      guarantors: (fields[16] as List).cast<String>(),
      collateral: fields[17] as String?,
      monthlyPayment: fields[18] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.principalAmount)
      ..writeByte(3)
      ..write(obj.interestRate)
      ..writeByte(4)
      ..write(obj.termInMonths)
      ..writeByte(5)
      ..write(obj.applicationDate)
      ..writeByte(6)
      ..write(obj.approvalDate)
      ..writeByte(7)
      ..write(obj.disbursementDate)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.purpose)
      ..writeByte(10)
      ..write(obj.approvedBy)
      ..writeByte(11)
      ..write(obj.disbursedBy)
      ..writeByte(12)
      ..write(obj.paidAmount)
      ..writeByte(13)
      ..write(obj.outstandingAmount)
      ..writeByte(14)
      ..write(obj.repayments)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.guarantors)
      ..writeByte(17)
      ..write(obj.collateral)
      ..writeByte(18)
      ..write(obj.monthlyPayment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanStatusAdapter extends TypeAdapter<LoanStatus> {
  @override
  final int typeId = 6;

  @override
  LoanStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanStatus.pending;
      case 1:
        return LoanStatus.approved;
      case 2:
        return LoanStatus.disbursed;
      case 3:
        return LoanStatus.active;
      case 4:
        return LoanStatus.completed;
      case 5:
        return LoanStatus.defaulted;
      case 6:
        return LoanStatus.cancelled;
      default:
        return LoanStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LoanStatus obj) {
    switch (obj) {
      case LoanStatus.pending:
        writer.writeByte(0);
        break;
      case LoanStatus.approved:
        writer.writeByte(1);
        break;
      case LoanStatus.disbursed:
        writer.writeByte(2);
        break;
      case LoanStatus.active:
        writer.writeByte(3);
        break;
      case LoanStatus.completed:
        writer.writeByte(4);
        break;
      case LoanStatus.defaulted:
        writer.writeByte(5);
        break;
      case LoanStatus.cancelled:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
