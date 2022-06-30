import 'package:eshopmultivendor/Helper/String.dart';

class TaxesModel {
  String? id, title, percentage, status;

  TaxesModel({
    this.id,
    this.title,
    this.percentage,
    this.status,
  });

  factory TaxesModel.fromJson(Map<String, dynamic> json) {
    return new TaxesModel(
      id: json[Id],
      title: json[Title],
      percentage: json[Percentage],
      status: json[STATUS],
    );
  }

  @override
  String toString() {
    return this.title!;
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.title}';
  }
}
