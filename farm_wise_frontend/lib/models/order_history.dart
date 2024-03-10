class OrderHistory {
  String orderId,
      productName,
      quantityUnit,
      dealerName,
      dealerMobile,
      productImageUrl;
  int dealPrice, orderQtyLots, totalOrdervalue;
  DateTime receivedOn, respondedOn, closedOn;
  bool isSellerClosed, isBuyerClosed, isOrderAccepted, isClosed;

  OrderHistory(
      {required this.productName,
      required this.orderId,
      required this.dealPrice,
      required this.orderQtyLots,
      required this.closedOn,
      required this.receivedOn,
      required this.respondedOn,
      required this.dealerMobile,
      required this.dealerName,
      required this.quantityUnit,
      required this.totalOrdervalue,
      required this.productImageUrl,
      required this.isSellerClosed,
      required this.isBuyerClosed,
      required this.isOrderAccepted,
      required this.isClosed});
}
