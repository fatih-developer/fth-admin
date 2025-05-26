import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String passwordHash;
  
  @HiveField(4)
  final String salt;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? passwordHash,
    String? salt,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
