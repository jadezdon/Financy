import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../models/account_model.dart';
import 'base_repository.dart';

class AccountRepository extends BaseRepository<AccountModel> {
  AccountRepository();

  @override
  Future<AccountModel> insert(AccountModel accountModel) async {
    final Database database = await DBProvider.instance.database;
    accountModel.id = await database.insert(
      AccountModel.tblAccount,
      accountModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return accountModel;
  }

  @override
  Future<List<AccountModel>> getAll() async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(AccountModel.tblAccount);

    return List.generate(
      result.length,
      (index) => AccountModel.fromMap(result[index]),
    );
  }

  @override
  Future<void> update(AccountModel accountModel) async {
    final Database database = await DBProvider.instance.database;
    await database.update(
      AccountModel.tblAccount,
      accountModel.toMap(),
      where: "${AccountModel.colId} = ?",
      whereArgs: [accountModel.id],
    );
  }

  Future<void> updateAll(List<AccountModel> accounts) async {
    final Database database = await DBProvider.instance.database;

    for (int i = 0; i < accounts.length; i++) {
      await database.update(
        AccountModel.tblAccount,
        accounts[i].toMap(),
        where: "${AccountModel.colId} = ?",
        whereArgs: [accounts[i].id],
      );
    }
  }

  @override
  Future<void> delete(AccountModel accountModel) async {
    final Database database = await DBProvider.instance.database;
    database.delete(
      AccountModel.tblAccount,
      where: "${AccountModel.colId} = ?",
      whereArgs: [accountModel.id],
    );
  }

  @override
  Future<AccountModel> getById(int id) {
    throw UnimplementedError();
  }
}
