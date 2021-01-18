import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../models/transaction_model.dart';
import 'base_repository.dart';

class TransactionRepository extends BaseRepository<TransactionModel> {
  @override
  Future<TransactionModel> insert(TransactionModel model) async {
    final Database database = await DBProvider.instance.database;
    model.id = await database.insert(
      TransactionModel.tblTransaction,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return model;
  }

  @override
  Future<List<TransactionModel>> getAll() async {
    final Database database = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await database.query(
      TransactionModel.tblTransaction,
    );

    return List.generate(
      result.length,
      (index) => TransactionModel.fromMap(result[index]),
    );
  }

  Future<List<TransactionModel>> getAllByLedgerId(int id) async {
    final Database database = await DBProvider.instance.database;
    final List<Map<String, dynamic>> result = await database.query(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colLedgerId} = ?",
      whereArgs: [id],
    );

    return List.generate(
      result.length,
      (index) => TransactionModel.fromMap(result[index]),
    );
  }

  @override
  Future<TransactionModel> getById(int id) async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colId} = ?",
      whereArgs: [id],
    );
    if (result.length > 0) {
      return TransactionModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> update(TransactionModel model) async {
    final Database database = await DBProvider.instance.database;
    await database.update(
      TransactionModel.tblTransaction,
      model.toMap(),
      where: "${TransactionModel.colId} = ?",
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> delete(TransactionModel model) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colId} = ?",
      whereArgs: [model.id],
    );
  }

  Future<void> deleteAllByCategoryId(int categoryId) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colCategoryId} = ?",
      whereArgs: [categoryId],
    );
  }

  Future<void> deleteAllByAccountId(int accountId) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colAccountId} = ?",
      whereArgs: [accountId],
    );
    await database.delete(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colTransferAccountId} = ?",
      whereArgs: [accountId],
    );
  }

  Future<void> deleteAllByLedgerId(int ledgerId) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      TransactionModel.tblTransaction,
      where: "${TransactionModel.colLedgerId} = ?",
      whereArgs: [ledgerId],
    );
  }
}
