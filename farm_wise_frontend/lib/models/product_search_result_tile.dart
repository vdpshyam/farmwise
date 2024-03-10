class ProductSearchResultTile {
  String productId, productName, quantityUnit, sellerName, location,productImageUrl;
  int basePrice;

  ProductSearchResultTile({
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.quantityUnit,
    required this.sellerName,
    required this.location,
    required this.productImageUrl
  });
}