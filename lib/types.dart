import 'dart:convert';

const prettyPrint = JsonEncoder.withIndent("  ");

abstract class JsonSerializable {
  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() {
    return prettyPrint.convert(toJson());
  }
}
