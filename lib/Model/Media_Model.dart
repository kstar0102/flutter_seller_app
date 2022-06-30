import 'package:eshopmultivendor/Helper/String.dart';

class MediaModel {
  String? id, name, image, extention, subDic, size;
  bool isSelected = false;
  MediaModel({
    this.id,
    this.name,
    this.image,
    this.extention,
    this.subDic,
    this.size,
    this.isSelected = false,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return new MediaModel(
        id: json[Id],
        name: json[Name],
        image: json[IMage],
        extention: json[EXTENSION],
        size: json[SIZE],
        subDic: json[SUB_DIC],
        isSelected: false);
  }
}
