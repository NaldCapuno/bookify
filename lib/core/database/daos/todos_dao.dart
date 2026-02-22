import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/todos_table.dart';

part 'todos_dao.g.dart';

@DriftAccessor(tables: [Todos])
class TodosDao extends DatabaseAccessor<AppDatabase> with _$TodosDaoMixin {
  TodosDao(super.db);

  // READ: Watch only the todos belonging to the specific user
  Stream<List<Todo>> watchTodosForUser(int currentUserId) {
    return (select(
      todos,
    )..where((t) => t.userId.equals(currentUserId))).watch();
  }

  // CREATE: Insert a new todo
  Future<int> insertTodo(TodosCompanion todo) => into(todos).insert(todo);

  // UPDATE: Toggle the completion status
  Future<bool> updateTodo(Todo todo) => update(todos).replace(todo);

  // DELETE: Remove a todo
  Future<int> deleteTodo(Todo todo) => delete(todos).delete(todo);
}
