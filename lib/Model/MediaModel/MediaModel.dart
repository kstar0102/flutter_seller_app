import 'package:eshopmultivendor/Helper/String.dart';

class MediaModel {
  String? id, name, image, extension, subDirectory, size;

  MediaModel({
    this.id,
    this.name,
    this.image,
    this.extension,
    this.subDirectory,
    this.size,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return new MediaModel(
      id: json[Id],
      name: json[Name],
      image: json[IMage],
      extension: json[Extension],
      subDirectory: json[SubDirectory],
      size: json[SIze],
    );
  }
}
