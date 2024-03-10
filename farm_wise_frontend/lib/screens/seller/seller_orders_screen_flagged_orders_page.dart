import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../custom_widgets/seller_orders_screen_flagged_orders_widget.dart';
import '../../providers/https_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_details_provider.dart';
import 'seller_order_details_screen.dart';

class SellerOrderScreenFlaggedOrdersPage extends StatefulWidget {
  const SellerOrderScreenFlaggedOrdersPage({super.key});

  @override
  State<SellerOrderScreenFlaggedOrdersPage> createState() =>
      _SellerOrderScreenFlaggedOrdersPageState();
}

class _SellerOrderScreenFlaggedOrdersPageState
    extends State<SellerOrderScreenFlaggedOrdersPage> {
  bool isLoading = true;
  late Uri flaggedOrdersUrl;

  void getFlaggedOrders() {
    http.get(flaggedOrdersUrl,
        headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}).then((response) {
      var flaggedOrdersUrlResp = json.decode(response.body);
      flaggedOrders.clear();
      if (flaggedOrdersUrlResp['message'] == 'Flagged orders recieved') {
        var orderDetails = flaggedOrdersUrlResp['orderDetails'];
        for (int i = 0; i < orderDetails.length; i++) {
          flaggedOrders.add(
            OrderScreenFlaggedOrderWidgetModel(
              orderId: orderDetails[i]["_id"],
              productName: orderDetails[i]["productDetails"][0]["productName"],
              dealPrice: orderDetails[i]["dealPrice"],
              orderQtyLots: orderDetails[i]["orderQtyLots"],
              orderValue: orderDetails[i]["orderValue"],
              productImages: orderDetails[i]["productDetails"][0]
                  ["productImages"],
              dealerName: orderDetails[i]["buyerDetails"][0]["userName"],
              quantityUnit: orderDetails[i]["productDetails"][0]
                  ["quantityUnit"],
            ),
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void updateFlaggedOrdersList(orderId) {
    setState(() {
      flaggedOrders.removeWhere((element) => element.orderId == orderId);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getFlaggedOrders();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    flaggedOrdersUrl = Uri.https(authority, 'api/farmer/getFlaggedOrders', {
      "id": loggedInUserDetails.userId,
    });
    getFlaggedOrders();
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
            child: flaggedOrders.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 120,
                        ),
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                              "lib/assets/images/flaggedorders1.png"),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 10),
                          child: Text(
                            "No Flagged orders. when your orders require any response, they appear here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: flaggedOrders.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SellerOrderDetailScreen(
                                orderId: flaggedOrders[index].orderId,
                                refreshFunc: _onRefresh,
                              ),
                            ),
                          );
                        },
                        child: SellerOrderScreenFlaggedOrderWidget(
                            order: flaggedOrders[index],
                            updateFlaggedOrdersFunc: updateFlaggedOrdersList),
                      );
                    },
                  ),
          );
  }
}
