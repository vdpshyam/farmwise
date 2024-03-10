// import '../models/product.dart';

class ListedItemsScreenProductModel {
  String productId, productName, quantityUnit;
  int basePrice, quantityPerLot, openOrders,minNoLot;
  List productImages;
  bool availStatus;

  ListedItemsScreenProductModel({
    required this.productId,
    required this.productName,
    required this.quantityUnit,
    required this.basePrice,
    required this.quantityPerLot,
    required this.productImages,
    required this.availStatus,
    required this.openOrders,
    required this.minNoLot,
  });
}

var product = ListedItemsScreenProductModel(
  productId: '',
  productName: '',
  quantityUnit: '',
  basePrice: 0,
  quantityPerLot: 0,
  openOrders: 0,
  minNoLot: 0,
  availStatus: false,
  productImages: [],
);

var productsList = <ListedItemsScreenProductModel>[];
