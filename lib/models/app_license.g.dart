// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_license.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppLicenseAdapter extends TypeAdapter<AppLicense> {
  @override
  final int typeId = 10;

  @override
  AppLicense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLicense(
      licenseCode: fields[0] as String,
      licenseType: fields[1] as LicenseType,
      activationDate: fields[2] as DateTime,
      expirationDate: fields[3] as DateTime?,
      enabledFeatures: (fields[4] as List).cast<String>(),
      deviceId: fields[5] as String,
      isActive: fields[6] as bool,
      metadata: (fields[7] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppLicense obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.licenseCode)
      ..writeByte(1)
      ..write(obj.licenseType)
      ..writeByte(2)
      ..write(obj.activationDate)
      ..writeByte(3)
      ..write(obj.expirationDate)
      ..writeByte(4)
      ..write(obj.enabledFeatures)
      ..writeByte(5)
      ..write(obj.deviceId)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLicenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LicenseTypeAdapter extends TypeAdapter<LicenseType> {
  @override
  final int typeId = 11;

  @override
  LicenseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LicenseType.trial;
      case 1:
        return LicenseType.full;
      case 2:
        return LicenseType.developer;
      default:
        return LicenseType.trial;
    }
  }

  @override
  void write(BinaryWriter writer, LicenseType obj) {
    switch (obj) {
      case LicenseType.trial:
        writer.writeByte(0);
        break;
      case LicenseType.full:
        writer.writeByte(1);
        break;
      case LicenseType.developer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LicenseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
