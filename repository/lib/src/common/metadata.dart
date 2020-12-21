/// Repository requestor.
///
///
class Requestor {
  const Requestor(
    this.endpoint,
    {
      this.putUrlExtension = '',
      this.patchUrlExtension = '',
      this.deleteUrlExtension = '',
      // this.subRequestors
    }
  );

  /// Http request URL endpoint.
  final String endpoint;
  /// Http PUT request URL extension. Will be appended after [endpoint].
  final String putUrlExtension;
  /// Http PATCH request URL extension. Will be appended after [endpoint].
  final String patchUrlExtension;
  /// Http DELETE request URL extension. Will be appended after [endpoint].
  final String deleteUrlExtension;
  // final List<_SubRequestor> subRequestors;
}

//-------------------------------------------------------------------
/// ID of the JSON response.
///
///
const Object HttpId = _ID();

/// Primary key of the datable table.
///
/// NOTE: Not yet implemented.
const Object DBId = _ID();

class _ID {
  const _ID();
}

//-------------------------------------------------------------------
/// JSON key/field.
///
/// This should be used if variable name is different
class Field {
  const Field({
    this.http,
    this.db,
  });

  final String http;
  final String db;
}

//-------------------------------------------------------------------
/// Ignore variable during code generation.
///
///
class Ignore {
  const Ignore({
    this.http = true,
    this.db = true,
  });

  final bool http;
  final bool db;
}