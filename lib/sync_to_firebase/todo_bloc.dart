import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'sync_firebase_repository.dart';
import 'sync_local_repository.dart';

import 'todo.dart';

class TodoBloc {
  //repo
  final SyncLocalRepository _localRepository = SyncLocalRepository();
  final SyncFirebaseRepository _firebaseRepository = SyncFirebaseRepository();

  final StreamController<List<Todo>> _todosController = StreamController();

  Stream<List<Todo>> get getTodos => _todosController.stream;

  List<Todo> _remoteTodos = [];
  List<Todo> _localTodos = [];
  bool flag = false;

  void requestGetFirebaseTodos() async {
    _remoteTodos.clear();
    Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection('MyTodos').snapshots();

    stream
        .map(
            (qShot) => qShot.docs.map((doc) => Todo.fromSnapshot(doc)).toList())
        .listen((todos) {
      _remoteTodos = todos;
      if (flag) {
        _localRepository.putAllTodos(todos);
        requestGetLocalTodos();
      }
    });
  }

  void requestGetLocalTodos() async {
    final localTodos = await _localRepository.getTodoList();
    _localTodos = localTodos;
    _todosController.sink.add(localTodos);
  }

  void syncTodos() async {
    //print the list get from firebase
    for (var item in _remoteTodos) {
      if (kDebugMode) {
        print('remote: ${item.toJson()}');
        print('remote ref: ${item.referenceId}');
      }
    }

    if (kDebugMode) {
      print('-------------------');
    }

    //print the list get from local
    for (var item in _localTodos) {
      if (kDebugMode) {
        print('local: ${item.toJson()}');
        print('local ref: ${item.referenceId}');
      }
    }

    if (kDebugMode) {
      print('-------------------');
    }

    //step to sync data local and firebase
    List<Todo> duplicatedTodos = [];
    if (_localTodos.isNotEmpty && _remoteTodos.isNotEmpty) {
      for (var local in _localTodos) {
        for (var remote in _remoteTodos) {
          //1. If same todoId
          if (local.todoId == remote.todoId) {
            //2. Get newest update time
            if (local.updateTime.isAfter(remote.updateTime)) {
              //2.1 If local is update after remote
              //create new to avoid reference with old list
              Todo newTodo = Todo(
                  todoId: local.todoId,
                  title: local.title,
                  description: local.description,
                  updateTime: local.updateTime,
                  referenceId: local.referenceId);
              duplicatedTodos.add(newTodo);
            } else {
              //2.2 If remote is update after local
              //create new to avoid reference with old list
              Todo newTodo = Todo(
                  todoId: remote.todoId,
                  title: remote.title,
                  description: remote.description,
                  updateTime: remote.updateTime,
                  referenceId: remote.referenceId);
              duplicatedTodos.add(newTodo);
            }

            //add flag for duplicate item is local and remote list
            local.todoId = -1;
            remote.todoId = -1;
          }
        }
      }

      //print duplicated list
      for (var item in duplicatedTodos) {
        if (kDebugMode) {
          print('duplicated: ${item.toJson()}');
          print('duplicated ref: ${item.referenceId}');
        }
      }
    }

    if (kDebugMode) {
      print('-------------------');
    }

    //merge duplicated, local and remote list then remove flag with id = -1;
    final mergedTodos = _localTodos + _remoteTodos + duplicatedTodos;
    mergedTodos.removeWhere((element) => element.todoId == -1);
    for (var item in mergedTodos) {
      if (kDebugMode) {
        print('merged: ${item.toJson()}');
        print('merged ref: ${item.referenceId}');
      }
    }

    //sync to server first for generated refID and store to local after that
    _firebaseRepository.putAllTodos(mergedTodos).then((_) {
      flag = true;
      requestGetFirebaseTodos();
    });
  }

  Future<int> getNextIndex() async {
    final list = await _localRepository.getTodoList();
    if (list.isEmpty) return 0;
    return list.length + 1;
  }

  void createLocalTodo(Todo todo) async {
    _localRepository.createTodo(todo);
  }

  void deleteTodo(Todo todo) async {
    _localRepository.deleteTodo(todo);
    _firebaseRepository.deleteTodo(todo);
    requestGetLocalTodos();
  }

  void updateTodo(Todo todo) async {}

  void dispose() {
    _todosController.close();
  }
}
