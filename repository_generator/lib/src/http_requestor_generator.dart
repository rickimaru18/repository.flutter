import 'dart:async';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:repository/repository.dart';
import 'package:source_gen/source_gen.dart';

class HttpRequestorGenerator extends GeneratorForAnnotation<Requestor> {
  String _parentClassName;
  String _className;
  String _endpoint;
  
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep
  ) {
    final StringBuffer sb = StringBuffer();
    _parentClassName = element.name;
    _className = '${_parentClassName}Requestor';
    _endpoint = annotation.objectValue.getField('endpoint').toStringValue();
    _endpoint = _endpoint.replaceAll('@', '\$');

    String putUrlExtension = annotation.objectValue.getField('putUrlExtension').toStringValue();
    putUrlExtension = putUrlExtension.replaceAll('@', '\$');
    String patchUrlExtension = annotation.objectValue.getField('patchUrlExtension').toStringValue();
    patchUrlExtension = patchUrlExtension.replaceAll('@', '\$');
    String deleteUrlExtension = annotation.objectValue.getField('deleteUrlExtension').toStringValue();
    deleteUrlExtension = deleteUrlExtension.replaceAll('@', '\$');
    
    final String tableName = annotation.objectValue.getField('tableName')?.toStringValue();

    sb.writeln('class $_className extends $_parentClassName');
    sb.writeln('with HttpRequestor, DBRequestor {');

    if (element is ClassElement) {
      _createConstructor(element.fields, sb);

      sb.writeln('@override');
      sb.writeln("String get endpoint => '$_endpoint';\n");

      if (putUrlExtension.isNotEmpty) {
        sb.writeln('@override');
        sb.writeln("String get putUrlExtension => '$putUrlExtension';\n");
      }

      if (patchUrlExtension.isNotEmpty) {
        sb.writeln('@override');
        sb.writeln("String get patchUrlExtension => '$patchUrlExtension';\n");
      }

      if (deleteUrlExtension.isNotEmpty) {
        sb.writeln('@override');
        sb.writeln("String get deleteUrlExtension => '$deleteUrlExtension';\n");
      }

      if (tableName != null && tableName.isNotEmpty) {
        sb.writeln('@override');
        sb.writeln("String get tableName => '$tableName';\n");
      }

      readFieldAnnotations(element.fields, sb);
      sb.writeln();
      
      // _generateForSubRequestors(
      //   annotation.objectValue.getField('subRequestors'),
      //   sb
      // );
      // readMethodAnnotations(element.methods, sb);
    }

    sb.writeln('}');
    return sb.toString();
  }

  ///
  ///
  ///
  void _createConstructor(
    List<FieldElement> fields,
    StringBuffer sb
  ) {
    sb.writeln('$_className({');

    for (final FieldElement field in fields) {
      sb.writeln('${field.type.getDisplayString(withNullability: false)} ${field.name},');
    }

    sb.writeln('}) {');

    for (final FieldElement field in fields) {
      sb.writeln('this.${field.name} = ${field.name};');
    }

    sb.writeln('}\n');
  }

  ///
  ///
  ///
  void readFieldAnnotations(
    List<FieldElement> fields,
    StringBuffer sb
  ) {
    final StringBuffer sbFromJson = StringBuffer();
    final StringBuffer sbToJson = StringBuffer();

    sbFromJson.writeln('@override');
    sbFromJson.writeln('$_className fromJson(Map<String, dynamic> json) {');
    sbFromJson.writeln('final $_parentClassName obj = $_className();');

    sbToJson.writeln('@override');
    sbToJson.writeln('Map<String, dynamic> toJson() => <String, dynamic>{');
    
    for (final FieldElement field in fields) {
      String jsonKey = field.name;
      bool isIgnoreField = false;

      for (final ElementAnnotation metadata in field.metadata) {
        if (metadata.toSource().startsWith('@HttpId')) {
          sb.writeln('@override');
          sb.writeln('String get endpointId => ${field.name}.toString();\n');
        } else if (metadata.toSource().startsWith('@DBId')) {
          sb.writeln('@override');
          sb.writeln('String get dbId => ${field.name}.toString();\n');
        } else if (metadata.toSource().startsWith('@Field')) {
          jsonKey = metadata.computeConstantValue()
              .getField('name').toStringValue();
        } else if (metadata.toSource().startsWith('@Ignore')) {
          isIgnoreField = true;
          break;
        }
      }

      if (isIgnoreField) {
        continue;
      }

      sbFromJson.writeln("obj.${field.name} = json['$jsonKey'] as ${field.type.getDisplayString(withNullability: false)};");
      
      sbToJson.writeln("'$jsonKey': ${field.name},");
    }

    sbFromJson.writeln('return obj;');
    sbFromJson.writeln('}');

    sbToJson.writeln('};');

    sb.write(sbFromJson.toString());
    sb.write(sbToJson.toString());
  }

  ///
  ///
  ///
  void _generateForSubRequestors(
    DartObject subRequestors,
    StringBuffer sb
  ) {
    if (subRequestors == null) {
      return;
    }

    final List<DartObject> subRequestorsAsList = subRequestors.toListValue();

    for (final DartObject subRequestor in subRequestorsAsList) {
      if (subRequestor.type.element.name == 'GET') {
        _generateHttpGetMethod(subRequestor, sb);
      }
    }
  }

  ///
  ///
  ///
  void _generateHttpGetMethod(
    DartObject subRequestor,
    StringBuffer sb
  ) {
    final String subEndpoint = subRequestor.getField('(super)')
        .getField('endpoint').toStringValue();
    final Map<DartObject, DartObject> params = subRequestor.getField('(super)')
        .getField('params').toMapValue();

    sb.writeln('@override');
    sb.writeln('Future<$_parentClassName> httpGet(');
    sb.writeln('String endpoint, {');
    sb.writeln('Map<String, dynamic> params');
    sb.writeln('}) async => await super.httpGet(');
    sb.write("'${_endpoint}'");

    if (subEndpoint != null) {
      sb.write('/');
      sb.write(subEndpoint);
    }
    
    if (params != null) {
      sb.writeln(",\nparams: ");
    }
    
    sb.writeln(');');
  }

  ///
  ///
  ///
  void readMethodAnnotations(
    List<MethodElement> methods,
    StringBuffer sb
  ) {
    for (final MethodElement method in methods) {
      for (final ElementAnnotation metadata in method.metadata) {
        if (metadata.toSource().startsWith('@GET')) {
          final String methodName = method.name;
          final String className = method.enclosingElement.name;
          final String subEndpoint = null;
          final Map<String, dynamic> params = null;

          sb.writeln('@override');
          // sb.write(method.returnType.getDisplayString());
          sb.writeln('Future<$_parentClassName> ${method.name}() async {');
          sb.writeln('return await httpGet(');
          sb.write("'${_endpoint}'");

          if (subEndpoint != null) {
            sb.write('/');
            sb.write(subEndpoint);
          }
          
          if (params != null) {
            sb.writeln(",\nparams: ");
          } else {
            sb.writeln(");");
          }
          
          sb.writeln('}');
        }
      }
    }
  }

  // DartObject getAnnotation(Element element) {
  //   final annotations = TypeChecker.fromRuntime(GET).annotationsOf(element);

  //   if (annotations.isEmpty) {
  //     return null;
  //   }
  //   if (annotations.length > 1) {
  //     throw Exception(
  //         "You tried to add multiple annotations to the "
  //         "same element (${element.name}), but that's not possible.");
  //   }

  //   return annotations.single;
  // }
  // @override
  // String generate(LibraryReader library, BuildStep buildStep) {
  //   final values = <String>{};

  //   for (var annotatedElement in library.annotatedWith(TypeChecker.fromRuntime(HttpRequestor))) {
  //     final generatedValue = generateForAnnotatedElement(
  //         annotatedElement.element, annotatedElement.annotation, buildStep);
  //     await for (var value in normalizeGeneratorOutput(generatedValue)) {
  //       assert(value == null || (value.length == value.trim().length));
  //       values.add(value);
  //     }
  //   }

  //   for (final element in library.allElements) {
  //     switch (element.runtimeType) {
  //       case HttpRequestor:
  //         values.add(generateForAnnotatedClass(
  //           element, element.annotation, buildStep
  //         ));
  //         break;
  //       case GET:

  //         break;
  //     }

      
  //     if (element is ClassElement && !element.isEnum) {
  //       for (final field in element.fields) {
  //         final annotation = getAnnotation(field);
          
  //         if (annotation != null) {
  //           values.add(generateForAnnotatedField(
  //             field,
  //             ConstantReader(annotation),
  //           ));
  //         }
  //       }
  //     }
  //   }

  //   return values.join('\n\n');
  // }

  // String generateForAnnotatedClass(
  //   Element element,
  //   ConstantReader annotation,
  //   BuildStep buildStep
  // ) {
  //   return 'class Shit {}';
  // }

  // String generateForAnnotatedField(
  //   FieldElement field,
  //   ConstantReader annotation
  // ) {
  //   final String fieldName = field.name;
  //   final String className = field.enclosingElement.name;
  //   final buffer = StringBuffer();

  //   buffer.writeAll([
  //     '// fieldName = $fieldName',
  //     '// className = $className',
  //   ].expand((line) => [line, '\n']));

  //   return buffer.toString();
  // }
}

// abstract class GeneratorForAnnotatedField<AnnotationType> extends Generator {
//   /// Returns the annotation of type [AnnotationType] of the given [element],
//   /// or [null] if it doesn't have any.
//   DartObject getAnnotation(Element element) {
//     final annotations =
//         TypeChecker.fromRuntime(AnnotationType).annotationsOf(element);

//     if (annotations.isEmpty) {
//       return null;
//     }
//     if (annotations.length > 1) {
//       throw Exception(
//           "You tried to add multiple @$AnnotationType() annotations to the "
//           "same element (${element.name}), but that's not possible.");
//     }

//     return annotations.single;
//   }

//   @override
//   String generate(LibraryReader library, BuildStep buildStep) {
//     final values = <String>{};

//     for (final element in library.allElements) {
//       if (element is ClassElement && !element.isEnum) {
//         for (final field in element.fields) {
//           final annotation = getAnnotation(field);
          
//           if (annotation != null) {
//             values.add(generateForAnnotatedField(
//               field,
//               ConstantReader(annotation),
//             ));
//           }
//         }
//       }
//     }

//     return values.join('\n\n');
//   }

//   String generateForAnnotatedField(
//       FieldElement field, ConstantReader annotation);
// }