import 'dart:io';

import 'package:example/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository/repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory dir = await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);
  
  await Repo.init(
    'https://jsonplaceholder.typicode.com',
    <Type, RequestorBuilder>{
      TodoRequestor: () => TodoRequestor(),
    },
    headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json'
    },
    dbPathAndName: join(dir.path, 'sample.db'),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(_) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTodoList(),
              _buildPostTile(context),
              _buildPutTile(context),
              _buildPatchTile(context),
              _buildDeleteTile(context),
            ],
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  Widget _buildTodoList() => FutureBuilder<List<Todo>>(
    future: Repo.httpGETList<TodoRequestor>(),
    initialData: [],
    builder: (_, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (snapshot.hasError) {
        return Center(
          child: Text('${snapshot.error.toString()}'),
        );
      } else if (snapshot.data == null) {
        return const Center(
          child: const Text('NULL DATA!'),
        );
      }

      final List<Todo> todos = snapshot.data;

      return Expanded(
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (_, int index) => ListTile(
            title: Text(todos[index].title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('ID: ${todos[index].id}'),
                Text('User ID: ${todos[index].userId}'),
                Text(todos[index].completed ? 'Completed' : 'TODO'),
              ],
            ),
          ),
        ),
      );
    },
  );

  ///
  ///
  ///
  Widget _buildPostTile(BuildContext context) => RaisedButton(
    onPressed: () async {
      TodoRequestor newTodo = TodoRequestor(
        id: 201,
        userId: 1,
        title: 'test POST',
        completed: false
      );

      newTodo = await Repo.httpPOST<TodoRequestor>(newTodo);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('POST new TODO result = ${newTodo?.toJson()}')
      ));
    },
    child: const Text('TEST POST'),
  );

  ///
  ///
  ///
  Widget _buildPutTile(BuildContext context) => RaisedButton(
    onPressed: () async {
      TodoRequestor updatedTodo = TodoRequestor(
        id: 1,
        userId: 1,
        title: 'test PUT',
        completed: false
      );

      updatedTodo = await Repo.httpPUT<TodoRequestor>(updatedTodo);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('PUT new TODO result = ${updatedTodo?.toJson()}')
      ));
    },
    child: const Text('TEST PUT'),
  );

  ///
  ///
  ///
  Widget _buildPatchTile(BuildContext context) => RaisedButton(
    onPressed: () async {
      final TodoRequestor existingTodo = TodoRequestor(
        id: 1,
        userId: 1,
        title: 'delectus aut autem',
        completed: false
      );
      final TodoRequestor patchedTodo = await Repo.httpPATCH<TodoRequestor>(
        existingTodo,
        <String, dynamic>{
          'title': 'test PATCH',
          'completed': true,
        },
      );
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('PATCH new TODO result = ${patchedTodo?.toJson()}')
      ));
    },
    child: const Text('TEST PATCH'),
  );

  ///
  ///
  ///
  Widget _buildDeleteTile(BuildContext context) => RaisedButton(
    onPressed: () async {
      final TodoRequestor existingTodo = TodoRequestor(
        id: 1,
        userId: 1,
        title: 'delectus aut autem',
        completed: false
      );
      final bool isDeleted = await Repo.httpDELETE<TodoRequestor>(
        existingTodo
      ) != null;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('DELETED TODO result = $isDeleted')
      ));
    },
    child: const Text('TEST DELETE'),
  );
}
