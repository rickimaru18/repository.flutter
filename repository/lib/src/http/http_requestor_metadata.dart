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