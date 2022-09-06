import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  int todoId;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  DateTime updateTime;
  @HiveField(4)
  String? referenceId;

  Todo(
      {this.referenceId,
      required this.todoId,
      required this.title,
      required this.description,
      required this.updateTime});

  factory Todo.fromSnapshot(DocumentSnapshot snapshot) {
    final newTodo = Todo.fromJson(snapshot.data() as Map<String, dynamic>);
    newTodo.referenceId = snapshot.reference.id;
    return newTodo;
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _todoFromJson(json);

  Map<String, dynamic> toJson() => _todoToJson(this);
}

Todo _todoFromJson(Map<String, dynamic> json) {
  return Todo(
      todoId: json['todoId'],
      title: json['title'],
      description: json['description'],
      updateTime: json['updateTime'].toDate()
  );
}

Map<String, dynamic> _todoToJson(Todo instance) => <String, dynamic>{
      'todoId': instance.todoId,
      'title': instance.title,
      'description': instance.description,
      'updateTime': instance.updateTime
    };
