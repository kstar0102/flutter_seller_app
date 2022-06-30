import 'package:eshopmultivendor/Helper/String.dart';

class ZipCodeModel {
  String? id,
      zipcode,
      dateCreated,
      img,
      status,
      balance,
      mobile,
      city,
      area,
      street;

  ZipCodeModel({
    this.id,
    this.zipcode,
    this.dateCreated,
  });

  factory ZipCodeModel.fromJson(Map<String, dynamic> json) {
    return new ZipCodeModel(
      id: json[Id],
      zipcode: json[Zipcode],
      dateCreated: json[DateCreated],
    );
  }
}
