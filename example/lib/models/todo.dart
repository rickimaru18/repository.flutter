import 'package:repository/repository.dart';

part 'todo.g.dart';

@Requestor(
  'todos',
  putUrlExtension: '@id',
  patchUrlExtension: '@id',
)
class Todo {
  @HttpId
  int id;
  int userId;
	String title;
	bool completed;
}