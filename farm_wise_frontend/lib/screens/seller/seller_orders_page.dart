// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'package:farm_wise_frontend/models/order.dart';
// import '../../custom_widgets/seller_orders_screen_active_orders_widget.dart';
// import '../../custom_widgets/seller_orders_screen_flagged_orders_widget.dart';
// import '../../custom_widgets/seller_orders_screen_pending_orders_widget.dart';
// import '../../custom_widgets/seller_ordersscreen_order_widget.dart';
// import '../../providers/https_provider.dart';
// import '../../providers/orders_provider.dart';
// import '../../providers/user_details_provider.dart';
// import 'seller_order_details_screen.dart';
import 'seller_orders_screen_active_orders_page.dart';
import 'seller_orders_screen_flagged_orders_page.dart';
import 'seller_orders_screen_pending_orders_page.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

// class OrderScreenPendingOrderWidgetModel{
//   String orderId,
//       productName,
//       quantityUnit;
//   int dealPrice, orderQtyLots;

//   DateTime
//       expectingResponseBefore,
//       recievedOn;

//   List productImages;

//   OrderScreenPendingOrderWidgetModel({
//     required this.orderId,
//     required this.productName,
//     required this.dealPrice,
//     required this.orderQtyLots,
//     required this.expectingResponseBefore,
//     required this.recievedOn,
//     required this.productImages,
//     required this.quantityUnit,
//   });
// }

class _SellerOrdersPageState extends State<SellerOrdersPage> {
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
  //             dealerName: orderDetails[i]["buyerDetails"][0]["userName"],
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
  //     pendingOrders.clear();
  //     if (pendingOrdersUrlResp['message'] == 'Pending orders recieved') {
  //       orderDetails = pendingOrdersUrlResp['orderDetails'];
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
  //             dealerName: orderDetails[i]["buyerDetails"][0]["userName"],
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

  // Future<void> _onRefresh() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   getPendingOrders();
  //   getActiveOrders();
  //   getFlaggedOrders();
  //   setState(() {
  //     isLoading = true;
  //   });
  //   return;
  // }

  @override
  void initState() {
    super.initState();
    // activeOrdersUrl = Uri.http(authority, 'api/farmer/getActiveOrders', {
    //   "id": loggedInUserDetails.userId,
    // });
    // pendingOrdersUrl = Uri.http(authority, 'api/farmer/getPendingOrders', {
    //   "id": loggedInUserDetails.userId,
    // });
    // flaggedOrdersUrl = Uri.http(authority, 'api/farmer/getFlaggedOrders', {
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
    return
        // isLoading
        //     ? const Center(
        //         child: CircularProgressIndicator(
        //           color: Color.fromARGB(255, 37, 143, 83),
        //         ),
        //       )
        //     :
        const DefaultTabController(
      length: 3,
      child: Scaffold(
          body: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                text: "Pending Orders",
                icon: Icon(Icons.pending_actions_outlined),
              ),
              Tab(
                text: "Active Orders",
                icon: Icon(
                  Icons.done_all,
                ),
              ),
              Tab(
                text: "Flagged Orders",
                icon: Icon(Icons.flag_outlined),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SellerOrdersCrennPendingOrdersPage(),
                // pendingOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding:
                //               EdgeInsets.symmetric(horizontal: 50.0),
                //           child: Text(
                //             "No pending orders. your received orders which are either to be accepted or rejected are shown here.",
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
                //                       SellerOrderDetailScreen(
                //                     orderId:
                //                         pendingOrders[index].orderId,
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: SellerOrderScreenPendingOrderWidget(
                //               order: pendingOrders[index],
                //             ),
                //           );
                //         },
                //       ),
                SellerOrderScreenActiveOrdersPage(),
                // acceptedOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding:
                //               EdgeInsets.symmetric(horizontal: 50.0),
                //           child: Text(
                //             "No active orders. your orders which you accepted, but are not closed yet are shown here.",
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
                //                       SellerOrderDetailScreen(
                //                     orderId:
                //                         acceptedOrders[index].orderId,
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: SellerOrderScreenActiveOrderWidget(
                //               order: acceptedOrders[index],
                //             ),
                //           );
                //         },
                //       ),
                SellerOrderScreenFlaggedOrdersPage(),
                // flaggedOrders.isEmpty
                //     ? const Center(
                //         child: Padding(
                //           padding:
                //               EdgeInsets.symmetric(horizontal: 50.0),
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
                //                       SellerOrderDetailScreen(
                //                     orderId:
                //                         flaggedOrders[index].orderId,
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: SellerOrderScreenFlaggedOrderWidget(
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
