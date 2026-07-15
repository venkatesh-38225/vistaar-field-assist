// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_details_hive_store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginDetailsAdapter extends TypeAdapter<LoginDetails> {
  @override
  final int typeId = 1;

  @override
  LoginDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginDetails(
      employeeId: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginDetails obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.employeeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
