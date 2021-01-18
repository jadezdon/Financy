abstract class BaseRepository<T> {
  Future<T> insert(T model);
  Future<List<T>> getAll();
  Future<T> getById(int id);
  Future<void> update(T model);
  Future<void> delete(T model);
}
