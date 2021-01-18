import 'package:Financy/data/app_database.dart';
import 'package:Financy/data/models/location_model.dart';
import 'package:Financy/data/repositories/base_repository.dart';
import 'package:sqflite/sqlite_api.dart';

class LocationRepository extends BaseRepository<LocationModel> {
  @override
  Future<LocationModel> insert(LocationModel model) async {
    final Database database = await DBProvider.instance.database;
    model.id = await database.insert(
      LocationModel.tblLocation,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return model;
  }

  @override
  Future<List<LocationModel>> getAll() async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(LocationModel.tblLocation);
    return List.generate(
      result.length,
      (index) => LocationModel.fromMap(result[index]),
    );
  }

  @override
  Future<LocationModel> getById(int id) async {
    final Database database = await DBProvider.instance.database;
    List<Map<String, dynamic>> result = await database.query(
      LocationModel.tblLocation,
      where: "${LocationModel.colId} = ?",
      whereArgs: [id],
    );

    if (result.length > 0) {
      return LocationModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> update(LocationModel model) async {
    final Database database = await DBProvider.instance.database;
    await database.update(
      LocationModel.tblLocation,
      model.toMap(),
      where: "${LocationModel.colId} = ?",
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> delete(LocationModel model) async {
    final Database database = await DBProvider.instance.database;
    await database.delete(
      LocationModel.tblLocation,
      where: "${LocationModel.colId} = ?",
      whereArgs: [model.id],
    );
  }
}
