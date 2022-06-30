import 'package:eshopmultivendor/Helper/String.dart';

class PersonModel {
  String? id, name, email, img, status, balance, mobile, city, area, street;

  PersonModel(
      {this.id,
      this.name,
      this.email,
      this.img,
      this.status,
      this.balance,
      this.mobile,
      this.city,
      this.area,
      this.street});

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return new PersonModel(
        id: json[Id],
        name: json[Name],
        email: json[Email],
        img: json[IMage],
        status: json[STATUS],
        mobile: json[Mobile],
        city: json[City] ?? "",
        area: json[Area] ?? "",
        street: json[STREET] ?? "",
        balance: json[BALANCE]);
  }

  @override
  String toString() {
    return this.name!;
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.name}';
  }
}
