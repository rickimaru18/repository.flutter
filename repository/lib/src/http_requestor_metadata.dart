const Object ID = _ID();
const Object Ignore = _Ignore();

///
///
///
class Requestor {
  const Requestor(
    this.endpoint, {
    this.subRequestors
  });

  final String endpoint;
  final List<_SubRequestor> subRequestors;
}

///
///
///
class Field {
  const Field(this.name);
  final String name;
}

///
///
///
class _ID {
  const _ID();
}

///
///
///
class _Ignore {
  const _Ignore();
}

///
///
///
class _SubRequestor {
  const _SubRequestor({
    this.endpoint,
    this.params
  });

  final String endpoint;
  final Map<String, dynamic> params;
}

///
///
///
class GET extends _SubRequestor {
  const GET({
    String endpoint,
    Map<String, dynamic> params
  }) : super(
    endpoint: endpoint,
    params: params
  );
}

///
///
///
class POST extends _SubRequestor {
  const POST({
    String endpoint,
    Map<String, dynamic> params
  }) : super(
    endpoint: endpoint,
    params: params
  );
}