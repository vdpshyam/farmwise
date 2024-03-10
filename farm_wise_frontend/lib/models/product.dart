class Product {
  String productId, userId, productName, quantityUnit, productDesc, location;
  DateTime producedDate, availableFrom;
  num basePrice, quantityPerLot, minNoLot, ratings;
  bool availStatus;
  List? productImages = [], reviews = [], ratedUser = [];

  Product({
    required this.productId,
    required this.userId,
    required this.productName,
    required this.quantityUnit,
    required this.productDesc,
    required this.producedDate,
    required this.availableFrom,
    required this.location,
    required this.basePrice,
    required this.quantityPerLot,
    required this.minNoLot,
    required this.ratings,
    required this.availStatus,
    required this.productImages,
    required this.reviews,
    required this.ratedUser,
  });
}
