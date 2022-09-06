import 'package:flutter/material.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/todo.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/todo_bloc.dart';

class SyncLocalPage extends StatefulWidget {
  const SyncLocalPage({Key? key}) : super(key: key);

  @override
  State<SyncLocalPage> createState() => _SyncLocalPageState();
}

class _SyncLocalPageState extends State<SyncLocalPage> {
  String title = "";
  String description = "";
  final TodoBloc _todoBloc = TodoBloc();

  @override
  void initState() {
    super.initState();
    _todoBloc.requestGetLocalTodos();
    _todoBloc.requestGetFirebaseTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync to Local"),
        actions: [
          IconButton(
              onPressed: () {
                _todoBloc.syncTodos();
              },
              icon: const Icon(Icons.sync))
        ],
      ),
      body: StreamBuilder<List<Todo>>(
        stream: _todoBloc.getTodos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasData || snapshot.data != null) {
            final todos = snapshot.data;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: todos?.length,
                itemBuilder: (BuildContext context, int index) {
                  final todo = todos![index];
                  return Dismissible(
                      key: Key(index.toString()),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text(todo.title),
                          subtitle: Text(todo.referenceId ?? "NULL"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _todoBloc.deleteTodo(todo);
                            },
                          ),
                        ),
                      ));
                });
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Text("Add Todo"),
                  content: SizedBox(
                    width: 400,
                    height: 100,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (String value) {
                            title = value;
                          },
                        ),
                        TextField(
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () async {
                          final todoId = await _todoBloc.getNextIndex();

                          if (title.isEmpty || description.isEmpty) {
                            return;
                          }

                          final todo = Todo(
                              todoId: todoId,
                              title: title,
                              description: description,
                              updateTime: DateTime.now());
                          _todoBloc.createLocalTodo(todo);
                          _todoBloc.requestGetLocalTodos();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add"))
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
