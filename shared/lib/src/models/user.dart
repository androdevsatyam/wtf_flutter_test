import 'package:meta/meta.dart';
import 'package:shared/src/rbac/role.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.assignedTrainerId,
  });

  final String id;
  final Role role;
  final String name;
  final String email;
  final String avatarUrl;
  final String? assignedTrainerId;

  User copyWith({
    String? id,
    Role? role,
    String? name,
    String? email,
    String? avatarUrl,
    String? assignedTrainerId,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'role': role.toWire(),
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'assignedTrainerId': assignedTrainerId,
      };

  static User fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as String,
      role: Role.fromWire(json['role'] as String),
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      assignedTrainerId: json['assignedTrainerId'] as String?,
    );
  }
}

