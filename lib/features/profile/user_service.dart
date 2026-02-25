import 'package:bookkeeping/core/database/daos/users_dao.dart';
import 'package:bookkeeping/core/database/app_database.dart';
// Make sure to import where you defined your BusinessType enum
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:drift/drift.dart';

class UserService {
  final UsersDao _usersDao;

  UserService(this._usersDao);

  /// Fetches the profile for the screen
  Future<User?> getUserProfile() async {
    return await _usersDao.getSingleUser();
  }

  /// Updates specific fields from the UI
  Future<bool> saveProfileUpdates({
    required int id,
    String? username,
    String? email,
    String? businessName,
    BusinessType? businessType,
    String? businessAddress,
    String? contactNumber,
  }) async {
    final companion = UsersCompanion(
      id: Value(id),
      username: username != null && username.isNotEmpty
          ? Value(username)
          : const Value.absent(),
      email: email != null && email.isNotEmpty
          ? Value(email)
          : const Value.absent(),
      business: businessName != null
          ? Value(businessName)
          : const Value.absent(),
      businessType: businessType != null
          ? Value(businessType)
          : const Value.absent(),
      businessAddress: businessAddress != null
          ? Value(businessAddress)
          : const Value.absent(),
      contactNumber: contactNumber != null
          ? Value(contactNumber)
          : const Value.absent(),
    );

    return await _usersDao.updateUser(companion);
  }
}
