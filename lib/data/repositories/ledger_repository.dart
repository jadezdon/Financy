import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../models/ledger_model.dart';
import 'base_repository.dart';

class LedgerRepository extends BaseRepository<LedgerModel> {
  LedgerRepository();

  @override
  Future<LedgerModel> insert(LedgerModel ledgerModel) async {
    final Database database = await DBProvider.instance.database;
    ledgerModel.id = await database.insert(
      LedgerModel.tblLedger,
      ledgerModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return ledgerModel;
  }

  @override
  Future<LedgerModel> getById(int id) async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(
      LedgerModel.tblLedger,
      where: "${LedgerModel.colId} = ?",
      whereArgs: [id],
    );

    if (result.length <= 0) {
      result = await database.query(
        LedgerModel.tblLedger,
        limit: 1,
      );
    }

    if (result.length > 0) {
      return LedgerModel.fromMap(result.first);
    }

    return null;
  }

  @override
  Future<List<LedgerModel>> getAll() async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(LedgerModel.tblLedger);

    List<LedgerModel> list = List.generate(
      result.length,
      (index) => LedgerModel.fromMap(result[index]),
    );

    return list;
  }

  @override
  Future<void> update(LedgerModel ledgerModel) async {
    final Database database = await DBProvider.instance.database;
    await database.update(
      LedgerModel.tblLedger,
      ledgerModel.toMap(),
      where: "${LedgerModel.colId} = ?",
      whereArgs: [ledgerModel.id],
    );
  }

  @override
  Future<void> delete(LedgerModel ledgerModel) async {
    final Database database = await DBProvider.instance.database;
    database.delete(
      LedgerModel.tblLedger,
      where: "${LedgerModel.colId} = ?",
      whereArgs: [ledgerModel.id],
    );
  }
}
