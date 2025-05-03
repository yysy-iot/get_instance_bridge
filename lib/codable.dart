import 'dart:convert' show jsonEncode;

mixin Encodable {
  ///
  Map<String, dynamic> toMap();

  ///
  String toJsonStr() => jsonEncode(toMap());
}
