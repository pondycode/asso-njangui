// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 1;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Member(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String?,
      phoneNumber: fields[4] as String,
      address: fields[5] as String?,
      dateOfBirth: fields[6] as DateTime,
      joinDate: fields[7] as DateTime,
      status: fields[8] as MemberStatus,
      profileImagePath: fields[9] as String?,
      nationalId: fields[10] as String?,
      occupation: fields[11] as String?,
      totalSavings: fields[12] as double,
      totalInvestments: fields[13] as double,
      emergencyFund: fields[14] as double,
      outstandingLoans: fields[15] as double,
      lastActivityDate: fields[16] as DateTime,
      metadata: (fields[17] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.dateOfBirth)
      ..writeByte(7)
      ..write(obj.joinDate)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.profileImagePath)
      ..writeByte(10)
      ..write(obj.nationalId)
      ..writeByte(11)
      ..write(obj.occupation)
      ..writeByte(12)
      ..write(obj.totalSavings)
      ..writeByte(13)
      ..write(obj.totalInvestments)
      ..writeByte(14)
      ..write(obj.emergencyFund)
      ..writeByte(15)
      ..write(obj.outstandingLoans)
      ..writeByte(16)
      ..write(obj.lastActivityDate)
      ..writeByte(17)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberStatusAdapter extends TypeAdapter<MemberStatus> {
  @override
  final int typeId = 0;

  @override
  MemberStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemberStatus.active;
      case 1:
        return MemberStatus.inactive;
      case 2:
        return MemberStatus.suspended;
      case 3:
        return MemberStatus.pending;
      default:
        return MemberStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, MemberStatus obj) {
    switch (obj) {
      case MemberStatus.active:
        writer.writeByte(0);
        break;
      case MemberStatus.inactive:
        writer.writeByte(1);
        break;
      case MemberStatus.suspended:
        writer.writeByte(2);
        break;
      case MemberStatus.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
