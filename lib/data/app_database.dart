import 'dart:io';

import 'package:Financy/data/models/location_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/data.dart';
import '../utils/number_util.dart';
import 'models/account_model.dart';
import 'models/category_model.dart';
import 'models/ledger_model.dart';
import 'models/transaction_model.dart';

class DBProvider {
  static final String databaseName = "financy.db";
  static final DBProvider instance = DBProvider._instance();
  static Database _database;

  DBProvider._instance();

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, databaseName);
    dPrint("create db at: $path");
    final financyDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return financyDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${CategoryModel.tblCategory} (
        ${CategoryModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryModel.colName} TEXT,
        ${CategoryModel.colIconCodePoint} INTEGER,
        ${CategoryModel.colIconFamily} TEXT,
        ${CategoryModel.colTransactionType} TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ${AccountModel.tblAccount} (
        ${AccountModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AccountModel.colName} TEXT,
        ${AccountModel.colBalance} REAL,
        ${AccountModel.colIconCodePoint} INTEGER,
        ${AccountModel.colIconFamily} TEXT
      )
      ''');

    await db.execute('''
      CREATE TABLE ${LedgerModel.tblLedger} (
        ${LedgerModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${LedgerModel.colName} TEXT,
        ${LedgerModel.colBudget} REAL
      )
      ''');

    await db.execute('''
      CREATE TABLE ${TransactionModel.tblTransaction} (
        ${TransactionModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TransactionModel.colAmount} REAL,
        ${TransactionModel.colDate} TEXT,
        ${TransactionModel.colRemark} TEXT,
        ${TransactionModel.colCategoryId} INTEGER,
        ${TransactionModel.colAccountId} INTEGER,
        ${TransactionModel.colLedgerId} INTEGER,
        ${TransactionModel.colImgUrl} TEXT,
        ${TransactionModel.colContact} TEXT,
        ${TransactionModel.colLocationId} INTEGER,
        ${TransactionModel.colTransferAccountId} INTEGER
      )
      ''');

    await db.execute(""" 
      CREATE TABLE ${LocationModel.tblLocation} (
        ${LocationModel.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${LocationModel.colLatitude} REAL,
        ${LocationModel.colLongitude} REAL,
        ${LocationModel.colCountry} TEXT,
        ${LocationModel.colCity} TEXT,
        ${LocationModel.colStreet} TEXT,
        ${LocationModel.colHouseNumber} TEXT
      )
    """);

    Batch batch = db.batch();
    AppData.ledgers.forEach((element) {
      batch.insert(LedgerModel.tblLedger, element.toMap());
    });
    AppData.accounts.forEach((element) {
      batch.insert(AccountModel.tblAccount, element.toMap());
    });
    batch.insert(CategoryModel.tblCategory, AppData.transferCategory.toMap());
    // batch.insert(CategoryModel.tblCategory, AppData.defaultExpenseCategory.toMap());
    // batch.insert(CategoryModel.tblCategory, AppData.defaultIncomeCategory.toMap());
    AppData.categories.forEach((element) {
      batch.insert(CategoryModel.tblCategory, element.toMap());
    });
    // AppData.transactions.forEach((element) {
    //   batch.insert(TransactionModel.tblTransaction, element.toMap());
    // });
    batch.commit();
  }
}
