import 'package:drift/drift.dart';

enum BusinessType {
  soleProprietorship,
  partnership,
  corporation,
  cooperative,
  onePersonCorporation,
  branchOffice,
  representativeOffice,
  freelancer,
}

// Extension to easily display the formatted text in the UI
extension BusinessTypeExtension on BusinessType {
  String get displayName {
    switch (this) {
      case BusinessType.soleProprietorship: return 'Sole Proprietorship';
      case BusinessType.partnership: return 'Partnership';
      case BusinessType.corporation: return 'Corporation';
      case BusinessType.cooperative: return 'Cooperative';
      case BusinessType.onePersonCorporation: return 'One Person Corporation (OPC)';
      case BusinessType.branchOffice: return 'Branch Office';
      case BusinessType.representativeOffice: return 'Representative Office';
      case BusinessType.freelancer: return 'Freelancer/Self-Employed';
    }
  }
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 1, max: 255)();
  TextColumn get email => text().withLength(min: 1, max: 255)();
  TextColumn get business => text().nullable().withLength(min: 0, max: 255)();
  TextColumn get businessType => textEnum<BusinessType>()(); // Uses the updated enum
  TextColumn get businessAddress => text().nullable().withLength(min: 0, max: 255)();
  TextColumn get contactNumber => text().nullable().withLength(min: 0, max: 255)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}