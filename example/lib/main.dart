import 'package:example/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

void main() {
  HttpRequestor.init(
    'https://jsonplaceholder.typicode.com',
    <Type, RequestorBuilder>{
      TodoRequestor: () => TodoRequestor(),
    },
    headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json'
    },
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTodoList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          TodoRequestor newTodo = TodoRequestor(
              id: 201, userId: 1, title: 'test POST', completed: false);

          newTodo = await HttpRequestor.post<TodoRequestor>(newTodo);
          print('!!!!!!!!! new TODO = ${newTodo.toJson()}');

          newTodo.id = 1;
          newTodo.title = 'test PUT';
          newTodo = await HttpRequestor.put<TodoRequestor>(newTodo);
          print('!!!!!!!!! new TODO = ${newTodo.toJson()}');

          newTodo =
              await HttpRequestor.patch<TodoRequestor>(newTodo, <String, bool>{
            'completed': true,
          });
          print('!!!!!!!!! new TODO = ${newTodo.toJson()}');
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  ///
  ///
  ///
  Widget _buildTodoList() => FutureBuilder<List<Todo>>(
        future: HttpRequestor.getList<TodoRequestor>(),
        initialData: [],
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                    Text(todos[index].completed ? 'Completed' : 'TODO'),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
