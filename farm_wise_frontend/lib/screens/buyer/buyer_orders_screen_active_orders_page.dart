import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../custom_widgets/buyer_orders_screen_active_orders_widget.dart';
import '../../providers/https_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_details_provider.dart';
import 'buyer_order_details_screen.dart';

class BuyerOrdersScreenActiveOrdersPage extends StatefulWidget {
  const BuyerOrdersScreenActiveOrdersPage({super.key});

  @override
  State<BuyerOrdersScreenActiveOrdersPage> createState() =>
      _BuyerOrdersScreenActiveOrdersPageState();
}

class _BuyerOrdersScreenActiveOrdersPageState
    extends State<BuyerOrdersScreenActiveOrdersPage> {
  late Uri activeOrdersUrl;
  bool isLoading = true;

  void getActiveOrders() {
    http.get(activeOrdersUrl,
        headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}).then((response) {
      var activeOrdersUrlResp = json.decode(response.body);
      if (activeOrdersUrlResp['message'] == 'Active orders recieved') {
        var orderDetails = activeOrdersUrlResp['orderDetails'];
        acceptedOrders.clear();
        for (int i = 0; i < orderDetails.length; i++) {
          acceptedOrders.add(
            OrderScreenActiveOrderWidgetModel(
              orderId: orderDetails[i]["_id"],
              productName: orderDetails[i]["productDetails"][0]["productName"],
              dealPrice: orderDetails[i]["dealPrice"],
              orderQtyLots: orderDetails[i]["orderQtyLots"],
              orderValue: orderDetails[i]["orderValue"],
              productImages: orderDetails[i]["productDetails"][0]
                  ["productImages"],
              dealerName: orderDetails[i]["sellerDetails"][0]["userName"],
              quantityUnit: orderDetails[i]["productDetails"][0]
                  ["quantityUnit"],
              isBuyerClosed: orderDetails[i]["isBuyerClosed"],
              isSellerClosed: orderDetails[i]["isSellerClosed"],
            ),
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  // void activeOrdersListUpdate(order) {
  //   print("Active list update");
  //   setState(() {
  //     acceptedOrders.;
  //   });
  // }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getActiveOrders();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    activeOrdersUrl = Uri.https(authority, 'api/common/getActiveOrders', {
      "id": loggedInUserDetails.userId,
    });
    getActiveOrders();
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
            child: acceptedOrders.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 120,
                        ),
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                            "lib/assets/images/activeorders1.png",
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0,vertical: 10),
                          child: Text(
                            "No active orders. your placed orders which are accepted by the seller, but not yet closed are shown here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: acceptedOrders.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BuyerOrderDetailScreen(
                                orderId: acceptedOrders[index].orderId,
                                refreshOrdersListFunc: _onRefresh,
                              ),
                            ),
                          );
                        },
                        child: BuyerOrderScreenActiveOrderWidget(
                          order: acceptedOrders[index],
                          // updateOrdersListFunc: activeOrdersListUpdate
                        ),
                      );
                    },
                  ),
          );
  }
}
