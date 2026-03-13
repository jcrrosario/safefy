import 'package:drift/drift.dart';

class VaultItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();
  TextColumn get category => text()();

  TextColumn get username => text().nullable()();
  TextColumn get password => text().nullable()();
  TextColumn get url => text().nullable()();

  TextColumn get content => text().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}