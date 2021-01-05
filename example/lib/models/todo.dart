import 'package:repository/repository.dart';

part 'todo.g.dart';

@Requestor(
  'todos',
  putUrlExtension: '@id',
  patchUrlExtension: '@id',
  deleteUrlExtension: '@id',
  tableName: 'todo',
)
class Todo {
  @HttpId
  @DBId
  int id;
  int userId;
	String title;
	bool completed;
}