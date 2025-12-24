// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryModelAdapter extends TypeAdapter<DiaryEntryModel> {
  @override
  final int typeId = 0;

  @override
  DiaryEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntryModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      body: fields[3] as String,
      tags: (fields[4] as List).cast<String>(),
      aiSummary: fields[5] as String?,
      aiMood: fields[6] as String?,
      aiConfidence: fields[7] as double?,
      aiRecommendations: (fields[8] as List?)?.cast<String>(),
      aiEmpathy: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isPendingAnalysis: fields[12] as bool,
      hasSafetyAlert: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntryModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.aiSummary)
      ..writeByte(6)
      ..write(obj.aiMood)
      ..writeByte(7)
      ..write(obj.aiConfidence)
      ..writeByte(8)
      ..write(obj.aiRecommendations)
      ..writeByte(9)
      ..write(obj.aiEmpathy)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isPendingAnalysis)
      ..writeByte(13)
      ..write(obj.hasSafetyAlert);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
