enum Role {
  trainer,
  member;

  static Role fromWire(String value) {
    switch (value) {
      case 'trainer':
        return Role.trainer;
      case 'member':
        return Role.member;
      default:
        throw ArgumentError.value(value, 'role', 'Unknown role');
    }
  }

  String toWire() => switch (this) {
        Role.trainer => 'trainer',
        Role.member => 'member',
      };
}

