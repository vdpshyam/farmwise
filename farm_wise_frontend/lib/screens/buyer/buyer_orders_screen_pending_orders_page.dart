import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../custom_widgets/buyer_orders_screen_pending_orders_widget.dart';
import '../../providers/https_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_details_provider.dart';
import 'buyer_order_details_screen.dart';

class BuyerOrdersScreenPendingOrdersPage extends StatefulWidget {
  const BuyerOrdersScreenPendingOrdersPage({super.key});

  @override
  State<BuyerOrdersScreenPendingOrdersPage> createState() =>
      _BuyerOrdersScreenPendingOrdersPageState();
}

class _BuyerOrdersScreenPendingOrdersPageState
    extends State<BuyerOrdersScreenPendingOrdersPage> {
  bool isLoading = true;
  late Uri pendingOrdersUrl;

  void getPendingOrders() {
    http.get(pendingOrdersUrl,
        headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}).then((response) {
      var pendingOrdersUrlResp = json.decode(response.body);
      if (pendingOrdersUrlResp['message'] == 'Pending orders recieved') {
        var orderDetails = pendingOrdersUrlResp['orderDetails'];
        pendingOrders.clear();
        for (int i = 0; i < orderDetails.length; i++) {
          pendingOrders.add(
            OrderScreenPendingOrderWidgetModel(
                orderId: orderDetails[i]["_id"],
                productName: orderDetails[i]["productDetails"][0]
                    ["productName"],
                dealPrice: orderDetails[i]["dealPrice"],
                orderQtyLots: orderDetails[i]["orderQtyLots"],
                expectingResponseBefore:
                    DateTime.parse(orderDetails[i]["expectingResponseBefore"]),
                recievedOn: DateTime.parse(orderDetails[i]["createdAt"]),
                productImages: orderDetails[i]["productDetails"][0]
                    ["productImages"],
                quantityUnit: orderDetails[i]["productDetails"][0]
                    ["quantityUnit"],
                dealerId: orderDetails[i]["sellerDetails"][0]["_id"]),
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void pendingOrdersListUpdate(orderId) {
    debugPrint("Pending list update");
    setState(() {
      pendingOrders.removeWhere((element) => element.orderId == orderId);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getPendingOrders();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    pendingOrdersUrl = Uri.http(authority, 'api/common/getPendingOrders', {
      "id": loggedInUserDetails.userId,
    });
    getPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 37, 143, 83),
            ),
          )
        : RefreshIndicator(
            onRefresh: _onRefresh,
            child: pendingOrders.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        SizedBox(
                          height: 250,
                          child: Image.asset(
                              "lib/assets/images/pendingorder1.png"),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: Text(
                            "No pending orders. your placed orders which are not yet accepted by the seller are shown here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: pendingOrders.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BuyerOrderDetailScreen(
                                orderId: pendingOrders[index].orderId,
                                refreshOrdersListFunc: _onRefresh,
                              ),
                            ),
                          );
                        },
                        child: BuyerOrderScreenPendingOrderWidget(
                          order: pendingOrders[index],
                          updateOrdersListFunc: pendingOrdersListUpdate,
                        ),
                      );
                    },
                  ),
          );
  }
}
