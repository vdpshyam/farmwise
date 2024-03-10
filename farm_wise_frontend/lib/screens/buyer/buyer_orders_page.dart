// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../custom_widgets/buyer_orders_screen_active_orders_widget.dart';
// import '../../custom_widgets/buyer_orders_screen_flagged_orders_widget.dart';
// import '../../custom_widgets/buyer_orders_screen_pending_orders_widget.dart';
// import '../../custom_widgets/buyer_ordersscreen_order_widget.dart';
// import '../../models/order.dart';
// import '../../providers/https_provider.dart';
// import '../../providers/orders_provider.dart';
// import '../../providers/user_details_provider.dart';
// import 'buyer_order_details_screen.dart';
import 'buyer_orders_screen_active_orders_page.dart';
import 'buyer_orders_screen_flagged_orders_page.dart';
import 'buyer_orders_screen_pending_orders_page.dart';

class BuyerOrdersPage extends StatefulWidget {
  const BuyerOrdersPage({super.key});

  @override
  State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
}

class _BuyerOrdersPageState extends State<BuyerOrdersPage> {
  // late Uri activeOrdersUrl, pendingOrdersUrl, flaggedOrdersUrl;
  // late Map<String, dynamic> activeOrdersUrlResp,
  //     pendingOrdersUrlResp,
  //     flaggedOrdersUrlResp;
  // List<dynamic> orderDetails = [];
  // bool isLoading = true;

  // void getActiveOrders() {
  //   http.get(activeOrdersUrl,
  //       headers: {'Content-Type': 'application/json'}).then((response) {
  //     activeOrdersUrlResp = json.decode(response.body);
  //     if (activeOrdersUrlResp['message'] == 'Active orders recieved') {
  //       orderDetails = activeOrdersUrlResp['orderDetails'];
  //       acceptedOrders.clear();
  //       for (int i = 0; i < orderDetails.length; i++) {
  //         acceptedOrders.add(
  //           OrderScreenActiveOrderWidgetModel(
  //             orderId: orderDetails[i]["_id"],
  //             productName: orderDetails[i]["productDetails"][0]["productName"],
  //             dealPrice: orderDetails[i]["dealPrice"],
  //             orderQtyLots: orderDetails[i]["orderQtyLots"],
  //             orderValue: orderDetails[i]["orderValue"],
  //             productImages: orderDetails[i]["productDetails"][0]
  //                 ["productImages"],
  //             dealerName: orderDetails[i]["sellerDetails"][0]["userName"],
  //             quantityUnit: orderDetails[i]["productDetails"][0]
  //                 ["quantityUnit"],
  //             isBuyerClosed: orderDetails[i]["isBuyerClosed"],
  //             isSellerClosed: orderDetails[i]["isSellerClosed"],
  //           ),
  //         );
  //       }
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  // void getPendingOrders() {
  //   http.get(pendingOrdersUrl,
  //       headers: {'Content-Type': 'application/json'}).then((response) {
  //     pendingOrdersUrlResp = json.decode(response.body);
  //     if (pendingOrdersUrlResp['message'] == 'Pending orders recieved') {
  //       orderDetails = pendingOrdersUrlResp['orderDetails'];
  //       pendingOrders.clear();
  //       for (int i = 0; i < orderDetails.length; i++) {
  //         pendingOrders.add(
  //           OrderScreenPendingOrderWidgetModel(
  //             orderId: orderDetails[i]["_id"],
  //             productName: orderDetails[i]["productDetails"][0]["productName"],
  //             dealPrice: orderDetails[i]["dealPrice"],
  //             orderQtyLots: orderDetails[i]["orderQtyLots"],
  //             expectingResponseBefore:
  //                 DateTime.parse(orderDetails[i]["expectingResponseBefore"]),
  //             recievedOn: DateTime.parse(orderDetails[i]["createdAt"]),
  //             productImages: orderDetails[i]["productDetails"][0]
  //                 ["productImages"],
  //             quantityUnit: orderDetails[i]["productDetails"][0]
  //                 ["quantityUnit"],
  //           ),
  //         );
  //       }
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  // void getFlaggedOrders() {
  //   http.get(flaggedOrdersUrl,
  //       headers: {'Content-Type': 'application/json'}).then((response) {
  //     flaggedOrdersUrlResp = json.decode(response.body);
  //     flaggedOrders.clear();
  //     if (flaggedOrdersUrlResp['message'] == 'Flagged orders recieved') {
  //       orderDetails = flaggedOrdersUrlResp['orderDetails'];
  //       for (int i = 0; i < orderDetails.length; i++) {
  //         flaggedOrders.add(
  //           OrderScreenFlaggedOrderWidgetModel(
  //             orderId: orderDetails[i]["_id"],
  //             productName: orderDetails[i]["productDetails"][0]["productName"],
  //             dealPrice: orderDetails[i]["dealPrice"],
  //             orderQtyLots: orderDetails[i]["orderQtyLots"],
  //             orderValue: orderDetails[i]["orderValue"],
  //             productImages: orderDetails[i]["productDetails"][0]
  //                 ["productImages"],
  //             dealerName: orderDetails[i]["sellerDetails"][0]["userName"],
  //             quantityUnit: orderDetails[i]["productDetails"][0]
  //                 ["quantityUnit"],
  //           ),
  //         );
  //       }
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // activeOrdersUrl = Uri.https(authority, 'api/common/getActiveOrders', {
    //   "id": loggedInUserDetails.userId,
    // });
    // pendingOrdersUrl = Uri.https(authority, 'api/common/getPendingOrders', {
    //   "id": loggedInUserDetails.userId,
    // });
    // flaggedOrdersUrl = Uri.https(authority, 'api/common/getFlaggedOrders', {
    //   "id": loggedInUserDetails.userId,
    // });
    // activeOrdersUrlResp = {};
    // pendingOrdersUrlResp = {};
    // flaggedOrdersUrlResp = {};
    // getPendingOrders();
    // getActiveOrders();
    // getFlaggedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
          body: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                text: "Placed Orders",
                icon: Icon(
                  Icons.pending_actions_outlined,
                ),
              ),
              Tab(
                text: "Accepted Orders",
                icon: Icon(
                  Icons.done_all,
                ),
              ),
              Tab(
                text: "Flagged Orders",
                icon: Icon(
                  Icons.flag_outlined,
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                BuyerOrdersScreenPendingOrdersPage(),
                // pendingOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 50.0),
                //           child: Text(
                //             "No pending orders. your placed orders which are not yet accepted by the seller are shown here.",
                //             textAlign: TextAlign.center,
                //             style: TextStyle(fontSize: 16),
                //           ),
                //         ),
                //       )
                //     : ListView.builder(
                //         itemCount: pendingOrders.length,
                //         itemBuilder: (context, index) {
                //           return InkWell(
                //             onTap: () {
                //               Navigator.of(context).push(
                //                 MaterialPageRoute(
                //                   builder: (BuildContext context) =>
                //                       BuyerOrderDetailScreen(
                //                     orderId: pendingOrders[index].orderId,
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: BuyerOrderScreenPendingOrderWidget(
                //               order: pendingOrders[index],
                //             ),
                //           );
                //         },
                //       ),
                BuyerOrdersScreenActiveOrdersPage(),
                // acceptedOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 50.0),
                //           child: Text(
                //             "No active orders. your placed orders which are accepted by the seller, but not yet closed are shown here.",
                //             textAlign: TextAlign.center,
                //             style: TextStyle(fontSize: 16),
                //           ),
                //         ),
                //       )
                //     : ListView.builder(
                //         itemCount: acceptedOrders.length,
                //         itemBuilder: (context, index) {
                //           return InkWell(
                //             onTap: () {
                //               Navigator.of(context).push(
                //                 MaterialPageRoute(
                //                   builder: (BuildContext context) =>
                //                       BuyerOrderDetailScreen(
                //                           orderId: acceptedOrders[index]
                //                               .orderId),
                //                 ),
                //               );
                //             },
                //             child: SellerOrderScreenActiveOrderWidget(
                //               order: acceptedOrders[index],
                //             ),
                //           );
                //         },
                //       ),
                BuyerOrdersScreenFlaggedOrdersPage(),
                // flaggedOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 50.0),
                //           child: Text(
                //             "No Flagged orders. when your orders require any response, they appear here.",
                //             textAlign: TextAlign.center,
                //             style: TextStyle(fontSize: 16),
                //           ),
                //         ),
                //       )
                //     : ListView.builder(
                //         itemCount: flaggedOrders.length,
                //         itemBuilder: (context, index) {
                //           return InkWell(
                //             onTap: () {
                //               Navigator.of(context).push(
                //                 MaterialPageRoute(
                //                   builder: (BuildContext context) =>
                //                       BuyerOrderDetailScreen(
                //                     orderId: flaggedOrders[index].orderId,
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: BuyerOrderScreenFlaggedOrderWidget(
                //               order: flaggedOrders[index],
                //             ),
                //           );
                //         },
                //       ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
