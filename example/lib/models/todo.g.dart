// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// HttpRequestorGenerator
// **************************************************************************

class TodoRequestor extends Todo with HttpRequestor {
  TodoRequestor({
    int id,
    int userId,
    String title,
    bool completed,
  }) {
    this.id = id;
    this.userId = userId;
    this.title = title;
    this.completed = completed;
  }

  @override
  String get endpoint => 'todos';

  @override
  String get putUrlExtension => '$id';

  @override
  String get patchUrlExtension => '$id';

  @override
  TodoRequestor fromJson(Map<String, dynamic> json) {
    final Todo obj = TodoRequestor();
    obj.id = json['id'] as int;
    obj.userId = json['userId'] as int;
    obj.title = json['title'] as String;
    obj.completed = json['completed'] as bool;
    return obj;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
      };
}
