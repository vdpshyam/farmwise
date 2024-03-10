class Order {
  String orderId,
      dealerId,
      productId,
      paymentMode,
      productName,
      dealerName,
      dealerMobile,
      quantityUnit;
  int basePrice, dealPrice, orderQtyLots, orderValue, minNoLot, quantityPerLot;
  bool isOrderAccepted,
      isClosed,
      halfPaymentDone,
      fullPaymentDone,
      isSellerClosed,
      isBuyerClosed;
  DateTime? closedOn,
      requiredOnOrBefore,
      expectingResponseBefore,
      recievedOn,
      sellerClosedOn,
      buyerClosedOn;
  List productImages;

  Order({
    required this.dealerId,
    required this.orderId,
    required this.productId,
    required this.minNoLot,
    required this.quantityPerLot,
    required this.productName,
    required this.paymentMode,
    required this.halfPaymentDone,
    required this.fullPaymentDone,
    required this.basePrice,
    required this.dealPrice,
    required this.orderQtyLots,
    required this.orderValue,
    required this.isOrderAccepted,
    required this.isClosed,
    required this.closedOn,
    required this.requiredOnOrBefore,
    required this.expectingResponseBefore,
    required this.recievedOn,
    required this.productImages,
    required this.dealerMobile,
    required this.dealerName,
    required this.quantityUnit,
    required this.buyerClosedOn,
    required this.isBuyerClosed,
    required this.isSellerClosed,
    required this.sellerClosedOn,
  });
}
