import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../models/category_model.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository<CategoryModel> {
  CategoryRepository();

  @override
  Future<CategoryModel> insert(CategoryModel categoryModel) async {
    final Database database = await DBProvider.instance.database;
    categoryModel.id = await database.insert(
      CategoryModel.tblCategory,
      categoryModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return categoryModel;
  }

  @override
  Future<List<CategoryModel>> getAll() async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(CategoryModel.tblCategory);

    return List.generate(
      result.length,
      (index) => CategoryModel.fromMap(result[index]),
    );
  }

  @override
  Future<CategoryModel> getById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> update(CategoryModel categoryModel) async {
    final Database database = await DBProvider.instance.database;
    await database.update(
      CategoryModel.tblCategory,
      categoryModel.toMap(),
      where: "${CategoryModel.colId} = ?",
      whereArgs: [categoryModel.id],
    );
  }

  @override
  Future<void> delete(CategoryModel categoryModel) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      CategoryModel.tblCategory,
      where: "${CategoryModel.colId} = ?",
      whereArgs: [categoryModel.id],
    );
  }
}
