import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/todo.dart';

class SyncFirebaseRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("MyTodos");

  Stream<QuerySnapshot> getTodosStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> createTodo(Todo todo) async {
    return await collection.add(todo.toJson());
  }

  Future<void> putAllTodos(List<Todo> todos) async {
    for (var todo in todos) {
      if (todo.referenceId == null) {
        print('create: ${todo.title}');
        createTodo(todo);
      } else {
        print('update: ${todo.title}');
        updateTodo(todo);
      }
    }
  }

  void updateTodo(Todo todo) async {
    var item = await collection.doc(todo.referenceId).get();
    if (item.exists) {
      await collection.doc(todo.referenceId).update(todo.toJson());
    }else{
      createTodo(todo);
    }
  }

  void deleteTodo(Todo todo) async {
    print('delete: ${todo.referenceId} - ${todo.todoId}');
    await collection.doc(todo.referenceId).delete();
  }
}
