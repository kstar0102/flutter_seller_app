import 'package:eshopmultivendor/Helper/String.dart';

class AttributeValueModel {
  String? id, value, attributeId, attributeName, status;

  AttributeValueModel(
      {this.id, this.value, this.status, this.attributeId, this.attributeName});

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    return new AttributeValueModel(
      id: json[Id],
      value: json[Value],
      status: json[STATUS],
      attributeId: json[AttributeId],
      attributeName: json[AttributeName],
    );
  }
}
