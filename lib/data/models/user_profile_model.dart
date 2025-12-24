import 'package:hive/hive.dart';
import 'package:mydairy/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 1)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final bool encryptionEnabled;

  @HiveField(3)
  final UserSettingsModel settings;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    this.name,
    this.encryptionEnabled = false,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      encryptionEnabled: encryptionEnabled,
      settings: settings.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      encryptionEnabled: profile.encryptionEnabled,
      settings: UserSettingsModel.fromEntity(profile.settings),
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}

@HiveType(typeId: 2)
class UserSettingsModel {
  @HiveField(0)
  final DateTime? reminderTime;

  @HiveField(1)
  final bool biometricEnabled;

  @HiveField(2)
  final bool backupEnabled;

  @HiveField(3)
  final String? groqApiKey;

  UserSettingsModel({
    this.reminderTime,
    this.biometricEnabled = false,
    this.backupEnabled = false,
    this.groqApiKey,
  });

  UserSettings toEntity() {
    return UserSettings(
      reminderTime: reminderTime,
      biometricEnabled: biometricEnabled,
      backupEnabled: backupEnabled,
      groqApiKey: groqApiKey,
    );
  }

  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      reminderTime: settings.reminderTime,
      biometricEnabled: settings.biometricEnabled,
      backupEnabled: settings.backupEnabled,
      groqApiKey: settings.groqApiKey,
    );
  }
}
