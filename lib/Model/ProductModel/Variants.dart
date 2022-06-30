import 'package:eshopmultivendor/Helper/String.dart';

class Product_Varient {
  String? id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
      availability,
      cartCount,
      stock,
      stockType,
      sku,
      stockStatus = '1';

  List<String>? images;
  List<String>? imagesUrl;

  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
      this.availability,
      this.cartCount,
      this.stock,
      this.images,
      this.imagesUrl,
      this.stockType,
      this.sku,
      this.stockStatus = '1'});

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[Images]);

    return new Product_Varient(
        id: json[Id],
        attribute_value_ids: json[AttributeValueIds],
        productId: json[ProductId],
        attr_name: json[AttrName],
        varient_value: json[VariantValues],
        disPrice: json[SpecialPrice],
        price: json[Price],
        availability: json[Availability].toString(),
        cartCount: json[CartCount],
        stock: json[Stock],
        stockType: json[Status],
        sku: json['sku'],
        images: images);
  }

  fromVariation(
      String id,
      String att,
      String disPrice,
      String price,
      String stockType,
      List<String> images,
      List<String> imagesUrl,
      String sku,
      String stock,
      String totalStock,
      String stkStatus) {
    return new Product_Varient(
        id: id,
        attr_name: att,
        disPrice: disPrice,
        price: price,
        images: images,
        imagesUrl: imagesUrl,
        sku: sku,
        stockType: stockType,
        stock: totalStock,
        stockStatus: stkStatus);
  }
}
