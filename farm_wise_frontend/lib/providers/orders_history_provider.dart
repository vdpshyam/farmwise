import 'package:farm_wise_frontend/models/order_history.dart';

var orderHistory = OrderHistory(
    orderId: '',
    productName: '',
    quantityUnit: '',
    dealerName: '',
    dealerMobile: '',
    productImageUrl: '',
    dealPrice: 0,
    orderQtyLots: 0,
    totalOrdervalue: 0,
    receivedOn: DateTime.now(),
    respondedOn: DateTime.now(),
    closedOn: DateTime.now(),
    isBuyerClosed: false,
    isClosed: false,
    isOrderAccepted: false,
    isSellerClosed: false);

var ordersHistory = <OrderHistory>[];
