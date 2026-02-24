import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:drift/drift.dart';
import 'package:bookkeeping/core/database/app_database.dart'; 

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<User?> getSingleUser() => select(users).getSingleOrNull();

  Future<bool> updateUser(UsersCompanion userCompanion) async {
    return await update(users).replace(userCompanion);
  }
}