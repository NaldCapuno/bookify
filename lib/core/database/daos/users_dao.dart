import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart'; // Drift will generate this specific file

// Tell Drift this DAO interacts with the Users table
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  // Move your register method here
  Future<int> registerUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // We can also prep a login query for later!
  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((t) => t.email.equals(email))).getSingleOrNull();
  }
}


