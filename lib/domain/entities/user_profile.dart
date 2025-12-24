import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? name;
  final bool encryptionEnabled;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.name,
    this.encryptionEnabled = false,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    bool? encryptionEnabled,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    encryptionEnabled,
    settings,
    createdAt,
    updatedAt,
  ];
}

class UserSettings extends Equatable {
  final DateTime? reminderTime;
  final bool biometricEnabled;
  final bool backupEnabled;
  final String? groqApiKey;

  const UserSettings({
    this.reminderTime,
    this.biometricEnabled = false,
    this.backupEnabled = false,
    this.groqApiKey,
  });

  UserSettings copyWith({
    DateTime? reminderTime,
    bool? biometricEnabled,
    bool? backupEnabled,
    String? groqApiKey,
  }) {
    return UserSettings(
      reminderTime: reminderTime ?? this.reminderTime,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      groqApiKey: groqApiKey ?? this.groqApiKey,
    );
  }

  @override
  List<Object?> get props => [
    reminderTime,
    biometricEnabled,
    backupEnabled,
    groqApiKey,
  ];
}
