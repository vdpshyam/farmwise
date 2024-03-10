import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/models/order_history.dart';
import 'package:farm_wise_frontend/providers/https_provider.dart';

import '../../custom_widgets/buyer_order_history_tile_widget.dart';
import 'package:farm_wise_frontend/providers/user_details_provider.dart';
import '../../providers/orders_history_provider.dart';
import 'buyer_order_details_screen.dart';

class BuyerOrdersHistoryScreen extends StatefulWidget {
  const BuyerOrdersHistoryScreen({super.key});

  @override
  State<BuyerOrdersHistoryScreen> createState() =>
      _BuyerOrdersHistoryScreenState();
}

class _BuyerOrdersHistoryScreenState extends State<BuyerOrdersHistoryScreen> {
  late Uri orderHistoryUrl;
  late Map<String, dynamic> orderHistoryResp;
  bool isLoading = true;
  List<dynamic> orderDetails = [];
  late String productName,
      quantityUnit,
      buyerName,
      buyerMobile,
      productImageUrl;
  late int dealPrice, orderQty, totalOrdervalue;
  late DateTime receivedOn, respondedOn, closedOn;

  void getOrdersHistory() {
    http.get(orderHistoryUrl, headers: {
      'Authorization': loggedInUserAuthToken,
      'Content-Type': 'application/json'
    }).then((response) {
      orderHistoryResp = json.decode(response.body);
      if (orderHistoryResp["message"] == "Orders history recieved") {
        orderDetails = orderHistoryResp["orderDetails"];
        ordersHistory.clear();
        if (orderDetails.isNotEmpty) {
          for (int i = 0; i < orderDetails.length; i++) {
            if (orderDetails[i]["sellerDetails"].length > 0 &&
                orderDetails[i]["productDetails"].length > 0) {
              ordersHistory.add(
                OrderHistory(
                  orderId: orderDetails[i]["_id"],
                  productName: orderDetails[i]["productDetails"][0]
                      ["productName"],
                  dealPrice: orderDetails[i]["dealPrice"],
                  orderQtyLots: orderDetails[i]["orderQtyLots"],
                  closedOn: DateTime.parse(orderDetails[i]["closedOn"]),
                  receivedOn: DateTime.parse(orderDetails[i]["createdAt"]),
                  respondedOn: DateTime.parse(orderDetails[i]["updatedAt"]),
                  dealerMobile: orderDetails[i]["sellerDetails"][0]["mobile"],
                  dealerName: orderDetails[i]["sellerDetails"][0]["userName"],
                  quantityUnit: orderDetails[i]["productDetails"][0]
                      ["quantityUnit"],
                  totalOrdervalue: orderDetails[i]["orderValue"],
                  productImageUrl: orderDetails[i]["productDetails"][0]
                      ["productImages"][0],
                  isBuyerClosed: orderDetails[i]["isBuyerClosed"],
                  isClosed: orderDetails[i]["isClosed"],
                  isOrderAccepted: orderDetails[i]["isOrderAccepted"],
                  isSellerClosed: orderDetails[i]["isSellerClosed"],
                ),
              );
            }
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getOrdersHistory();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    orderHistoryUrl = Uri.https(authority, 'api/common/getOrdersHistory', {
      "id": loggedInUserDetails.userId,
    });
    orderDetails = [];
    getOrdersHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 37, 143, 83),
              ),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ordersHistory.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 180,
                          ),
                          SizedBox(
                            height: 200,
                            child: Image.asset(
                                "lib/assets/images/ordershistory1.png"),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 10),
                            child: Text(
                              "No closed orders yet. Yours closed deals appear here. See for any open orders from the orders tab.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: ordersHistory.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return BuyerOrderDetailScreen(
                                    orderId: ordersHistory[index].orderId,
                                    refreshOrdersListFunc: () {},
                                  );
                                },
                              ),
                            );
                          },
                          child: BuyerOrdersHistoryOrderItemWidget(
                            productName: ordersHistory[index].productName,
                            dealPrice: ordersHistory[index].dealPrice,
                            quantityUnit: ordersHistory[index].quantityUnit,
                            orderQtyLots: ordersHistory[index].orderQtyLots,
                            receivedOn: ordersHistory[index].receivedOn,
                            respondedOn: ordersHistory[index].respondedOn,
                            closedOn: ordersHistory[index].closedOn,
                            sellerName: ordersHistory[index].dealerName,
                            sellerMobile: ordersHistory[index].dealerMobile,
                            totalOrdervalue:
                                ordersHistory[index].totalOrdervalue,
                            productImageUrl:
                                ordersHistory[index].productImageUrl,
                            isBuyerClosed: orderDetails[index]["isBuyerClosed"],
                            isClosed: orderDetails[index]["isClosed"],
                            isOrderAccepted: orderDetails[index]
                                ["isOrderAccepted"],
                            isSellerClosed: orderDetails[index]
                                ["isSellerClosed"],
                          ),
                        );
                      }),
            ),
    );
  }
}
