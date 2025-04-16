import 'dart:convert' show jsonEncode;

typedef Decodable<T> = T Function(Map<String, dynamic> json);

mixin Encodable {
  ///
  Map<String, dynamic> toMap();

  ///
  String toJsonStr() => jsonEncode(toMap());
}
