import '../models/order.dart';

class OrderScreenPendingOrderWidgetModel {
  String orderId, productName, quantityUnit,dealerId;
  int dealPrice, orderQtyLots;
  DateTime expectingResponseBefore, recievedOn;
  List productImages;

  OrderScreenPendingOrderWidgetModel({
    required this.orderId,
    required this.dealerId,
    required this.productName,
    required this.dealPrice,
    required this.orderQtyLots,
    required this.expectingResponseBefore,
    required this.recievedOn,
    required this.productImages,
    required this.quantityUnit,
  });
}

class OrderScreenActiveOrderWidgetModel {
  String orderId, productName, quantityUnit,dealerName;
  int dealPrice, orderQtyLots,orderValue;
  bool isBuyerClosed, isSellerClosed;

  List productImages;

  OrderScreenActiveOrderWidgetModel({
    required this.orderId,
    required this.productName,
    required this.isBuyerClosed,
    required this.isSellerClosed,
    required this.dealerName,
    required this.orderValue,
    required this.dealPrice,
    required this.orderQtyLots,
    required this.productImages,
    required this.quantityUnit,
  });
}

class OrderScreenFlaggedOrderWidgetModel {
  String orderId, productName, quantityUnit,dealerName;
  int dealPrice, orderQtyLots,orderValue;
  List productImages;

  OrderScreenFlaggedOrderWidgetModel({
    required this.orderId,
    required this.productName,
    required this.dealerName,
    required this.orderValue,
    required this.dealPrice,
    required this.orderQtyLots,
    required this.productImages,
    required this.quantityUnit,
  });
}

var order = Order(
  orderId: '',
  productId: '',
  minNoLot: 0,
  quantityPerLot: 0,
  productName: '',
  paymentMode: '',
  halfPaymentDone: false,
  fullPaymentDone: false,
  basePrice: 0,
  dealPrice: 0,
  orderQtyLots: 0,
  orderValue: 0,
  isOrderAccepted: false,
  isClosed: false,
  closedOn: DateTime.now(),
  requiredOnOrBefore: DateTime.now(),
  expectingResponseBefore: DateTime.now(),
  recievedOn: DateTime.now(),
  productImages: [],
  dealerId: '',
  dealerMobile: '',
  dealerName: '',
  quantityUnit: '',
  buyerClosedOn: DateTime.now(),
  isBuyerClosed: false,
  isSellerClosed: false,
  sellerClosedOn: DateTime.now(),
);

var acceptedOrders = <OrderScreenActiveOrderWidgetModel>[];
var pendingOrders = <OrderScreenPendingOrderWidgetModel>[];
var flaggedOrders = <OrderScreenFlaggedOrderWidgetModel>[];
