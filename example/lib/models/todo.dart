import 'package:repository/repository.dart';

part 'todo.g.dart';

@Requestor('todos')
class Todo {
  @ID
  int id;
  int userId;
	String title;
	bool completed;
}