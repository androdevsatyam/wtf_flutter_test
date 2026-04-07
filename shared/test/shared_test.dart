import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(SeedData.initialUsers.length, 2);
      expect(SeedData.trainerAarav.role, Role.trainer);
      expect(SeedData.memberDk.role, Role.member);
    });
  });
}
