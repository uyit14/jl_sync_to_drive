import 'package:hive/hive.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/todo.dart';

class SyncLocalRepository {
  Future<List<Todo>> getTodoList() async {
    final box = Hive.box<Todo>('todo');
    return box.values.toList();
  }

  Future<void> createTodo(Todo todo) async {
    final box = Hive.box<Todo>('todo');
    await box.put(todo.todoId, todo);
  }

  Future<void> putAllTodos(List<Todo> todos) async {
    for(var item in todos){
      print('item putTodos: ${item.toJson()}');
      print('ref: ${item.referenceId}');
    }
    final box = Hive.box<Todo>('todo');
    Map<int, Todo> todosMap = {for (var item in todos) item.todoId: item};
    await box.putAll(todosMap);
  }

  void deleteTodo(Todo todo) async {
    final box = Hive.box<Todo>('todo');
    await box.delete(todo.todoId);
  }

  void updateTodo(Todo todo) {
    final box = Hive.box<Todo>('todo');
    box.put(todo.todoId, todo);
  }
}
