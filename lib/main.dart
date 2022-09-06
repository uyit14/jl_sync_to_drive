import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/sync_local_page.dart';
import 'package:jl_sync_to_drive/sync_to_firebase/todo.dart';
import 'package:path_provider/path_provider.dart';
import 'sync_to_drive/firebase_options.dart';
import 'sync_to_drive/sync_drive_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory applicationDocumentDir;
  if(kIsWeb){
    applicationDocumentDir = await getTemporaryDirectory();
  }else{
    applicationDocumentDir = await getApplicationDocumentsDirectory();
  }

  Hive.init(applicationDocumentDir.path);

  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todo');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SyncLocalPage(),
    );
  }
}
