library repository_generator;

import 'package:build/build.dart';
import 'package:repository_generator/src/http_requestor_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder httpRequestor(BuilderOptions options) =>
    SharedPartBuilder([HttpRequestorGenerator()], 'http_requestor');