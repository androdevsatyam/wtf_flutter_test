import 'package:shared/src/models/user.dart';
import 'package:shared/src/rbac/role.dart';

class SeedData {
  static const String trainerAaravId = 'trainer_aarav';
  static const String memberDkId = 'member_dk';

  static const User trainerAarav = User(
    id: trainerAaravId,
    role: Role.trainer,
    name: 'Aarav (Lead Trainer)',
    email: 'aarav.trainer@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    assignedTrainerId: null,
  );

  static const User memberDk = User(
    id: memberDkId,
    role: Role.member,
    name: 'DK',
    email: 'dk.member@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    assignedTrainerId: trainerAaravId,
  );

  static const List<User> initialUsers = <User>[
    trainerAarav,
    memberDk,
  ];
}

