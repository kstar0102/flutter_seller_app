import 'package:eshopmultivendor/Helper/String.dart';

class Filter {
  String? attributeValues, attributeValuesId, name, swatcheType, swatcheValue;

  Filter({
    this.attributeValues,
    this.attributeValuesId,
    this.name,
    this.swatcheType,
    this.swatcheValue,
  });
  factory Filter.fromJson(Map<String, dynamic> json) {
    return new Filter(
        attributeValues: json[AttributeValues],
        attributeValuesId: json[AttributeValuesId],
        name: json[Name],
        swatcheType: json[SwatchType],
        swatcheValue: json[SwatcheValue]);
  }
}
