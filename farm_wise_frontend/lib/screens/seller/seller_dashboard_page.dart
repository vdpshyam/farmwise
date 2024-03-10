import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../../models/order.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import 'seller_order_details_screen.dart';
import 'seller_view_listed_item_screen.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class TopProductsSold {
  int topProductsSoldSales = 0, basePrice = 0;
  String productName = '', productId = '', quantityUnit = '';
  List productImages = [];

  TopProductsSold({
    required this.productId,
    required this.topProductsSoldSales,
    required this.basePrice,
    required this.productName,
    required this.quantityUnit,
    required this.productImages,
  });
}

class RecentReceivedOrders {
  int orderValue = 0, dealPrice = 0, basePrice;
  String productName = '', orderId = '', quantityUnit = '', dealerName = '';
  List productImages = [];
  DateTime expectingResponseBefore = DateTime.now();

  RecentReceivedOrders({
    required this.orderId,
    required this.orderValue,
    required this.dealPrice,
    required this.dealerName,
    required this.basePrice,
    required this.productName,
    required this.quantityUnit,
    required this.productImages,
    required this.expectingResponseBefore,
  });
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late Uri getDashboardStatsUrl;
  bool isLoading = true;

  int productCount = 0;

  final List<TopProductsSold> _topProductsSoldList = [];

  final List<RecentReceivedOrders> _recentReceivedOrders = [];

  int totalSales = 0,
      totalListedProducts = 0,
      totalOrders = 0,
      completedOrders = 0,
      rejectedOrders = 0,
      acceptedOrders = 0,
      pendingOrders = 0,
      activeOrders = 0,
      flagWaitingBuyerApprovalOrders = 0,
      flagedOrders = 0;

  void getDashboardStats() {
    _recentReceivedOrders.clear();
    _topProductsSoldList.clear();
    http.get(getDashboardStatsUrl, headers: {
      'Authorization': loggedInUserAuthToken,
      'Content-Type': 'application/json'
    }).then((response) {
      if (response.statusCode == 200) {
        var getDashboardStatsResp = json.decode(response.body);
        // print(getDashboardStatsResp);
        if (getDashboardStatsResp["message"] == "Dashboard stats received") {
          totalListedProducts = getDashboardStatsResp["data"]["productCount"];
          if (getDashboardStatsResp["data"]["totalSales"].length > 0) {
            totalSales =
                getDashboardStatsResp["data"]["totalSales"][0]["totalSales"];
          }
          if (getDashboardStatsResp["data"]["completedOrders"].length > 0) {
            completedOrders = getDashboardStatsResp["data"]["completedOrders"]
                [0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["pendingOrders"].length > 0) {
            pendingOrders =
                getDashboardStatsResp["data"]["pendingOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["activeOrders"].length > 0) {
            activeOrders =
                getDashboardStatsResp["data"]["activeOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["flagWaitingBuyerApprovalOrders"]
                  .length >
              0) {
            flagWaitingBuyerApprovalOrders = getDashboardStatsResp["data"]
                ["flagWaitingBuyerApprovalOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["flagedOrders"].length > 0) {
            flagedOrders =
                getDashboardStatsResp["data"]["flagedOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["totalOrders"].length > 0) {
            totalOrders =
                getDashboardStatsResp["data"]["totalOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["acceptedOrders"].length > 0) {
            getDashboardStatsResp["data"]["acceptedOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["rejectedOrders"].length > 0) {
            acceptedOrders = rejectedOrders = getDashboardStatsResp["data"]
                ["rejectedOrders"][0]["totalCount"];
          }
          if (getDashboardStatsResp["data"]["topProductsSold"].length > 0) {
            for (int i = 0;
                i < getDashboardStatsResp["data"]["topProductsSold"].length;
                i++) {
              _topProductsSoldList.add(
                TopProductsSold(
                  productId: getDashboardStatsResp["data"]["topProductsSold"][i]
                      ["_id"][0],
                  topProductsSoldSales: getDashboardStatsResp["data"]
                      ["topProductsSold"][i]["totalSales"],
                  basePrice: getDashboardStatsResp["data"]["topProductsSold"][i]
                      ["productDetails"][0]["basePrice"],
                  productName: getDashboardStatsResp["data"]["topProductsSold"]
                      [i]["productDetails"][0]["productName"],
                  quantityUnit: getDashboardStatsResp["data"]["topProductsSold"]
                      [i]["productDetails"][0]["quantityUnit"],
                  productImages: getDashboardStatsResp["data"]
                          ["topProductsSold"][i]["productDetails"][0]
                      ["productImages"],
                ),
              );
            }
          }
          if (getDashboardStatsResp["data"]["recentReceivedOrders"].length >
              0) {
            for (int i = 0;
                i <
                    getDashboardStatsResp["data"]["recentReceivedOrders"]
                        .length;
                i++) {
              _recentReceivedOrders.add(
                RecentReceivedOrders(
                  orderId: getDashboardStatsResp["data"]["recentReceivedOrders"]
                      [i]["_id"],
                  orderValue: getDashboardStatsResp["data"]
                      ["recentReceivedOrders"][i]["orderValue"],
                  dealPrice: getDashboardStatsResp["data"]
                      ["recentReceivedOrders"][i]["dealPrice"],
                  dealerName: getDashboardStatsResp["data"]
                      ["recentReceivedOrders"][i]["userDetails"][0]["userName"],
                  basePrice: getDashboardStatsResp["data"]
                          ["recentReceivedOrders"][i]["productDetails"][0]
                      ["basePrice"],
                  productName: getDashboardStatsResp["data"]
                          ["recentReceivedOrders"][i]["productDetails"][0]
                      ["productName"],
                  quantityUnit: getDashboardStatsResp["data"]
                          ["recentReceivedOrders"][i]["productDetails"][0]
                      ["quantityUnit"],
                  productImages: getDashboardStatsResp["data"]
                          ["recentReceivedOrders"][i]["productDetails"][0]
                      ["productImages"],
                  expectingResponseBefore: DateTime.parse(
                      getDashboardStatsResp["data"]["recentReceivedOrders"][i]
                          ["expectingResponseBefore"]),
                ),
              );
            }
          }
        } else {
          final snackBar = SnackBar(
            content: const Text('Could not load dashbaord.Try again later.'),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(
          content: const Text('Something went wrong.Try again later.'),
          action: SnackBarAction(
            label: 'okay',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getDashboardStats();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    getDashboardStatsUrl = Uri.https(authority, 'api/farmer/getDashboardStats', {
      "userId": loggedInUserDetails.userId,
    });
    getDashboardStats();
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
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 27, 156, 115),
                    ),
                    child: Column(
                      children: [
                        const Divider(
                          height: 0.7,
                          color: Colors.grey,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Total Sales",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                // Text(
                                //   "2023 Q2",
                                //   style: TextStyle(
                                //     fontSize: 20,
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Rs.$totalSales",
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 25,
                                ),
                                const Text(
                                  "Closed orders",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                // Text(
                                //   "2023 Q2",
                                //   style: TextStyle(fontSize: 20),
                                // ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "$completedOrders",
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Divider(
                            height: 0,
                            indent: 45,
                            endIndent: 45,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Orders stats :",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(252, 236, 238, 230),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Overall orders stats :",
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "Total received",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$totalOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Accepted",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$acceptedOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Rejected",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$rejectedOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Current orders stats :",
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "Pending",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$pendingOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Active",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$activeOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Flagged",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "$flagedOrders",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      const Text(
                                        "Waiting for buyer approval to close:  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "$flagWaitingBuyerApprovalOrders",
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Divider(
                            height: 0,
                            indent: 45,
                            endIndent: 45,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 25,
                              ),
                              const Text(
                                "Total listed products : ",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "$totalListedProducts",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    "Top Products sold :",
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              _topProductsSoldList.isEmpty
                                  ? Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          height: 150,
                                          child: Image.asset(
                                            "lib/assets/images/product2.png",
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 70,
                                          width: double.maxFinite,
                                          child: Center(
                                            child: Text(
                                              "No top sold products yet.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _topProductsSoldList.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return SellerViewListedItemScreen(
                                                    productId:
                                                        _topProductsSoldList[
                                                                index]
                                                            .productId,
                                                    refresh: _onRefresh,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      173, 13, 95, 69),
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 13, 95, 69),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${index + 1}",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  117,
                                                                  160,
                                                                  159,
                                                                  159),
                                                              // border: Border(
                                                              //   top: BorderSide(
                                                              //     width: 0.5,
                                                              //     color: Colors.black,
                                                              //   ),
                                                              //   left: BorderSide(
                                                              //     width: 0.5,
                                                              //     color: Colors.black,
                                                              //   ),
                                                              //   right: BorderSide(
                                                              //     width: 0.5,
                                                              //     color: Colors.black,
                                                              //   ),
                                                              //   bottom: BorderSide(
                                                              //     width: 0.5,
                                                              //     color: Colors.black,
                                                              //   ),
                                                              // ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                            ),
                                                            height: 70,
                                                            width: 70,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              child:
                                                                  Image.network(
                                                                _topProductsSoldList[
                                                                        index]
                                                                    .productImages[0],
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                _topProductsSoldList[
                                                                        index]
                                                                    .productName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                "Price : ${_topProductsSoldList[index].basePrice}/${_topProductsSoldList[index].quantityUnit}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                "Total sales : Rs.${_topProductsSoldList[index].topProductsSoldSales}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            width: 60,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  const Divider(
                                                    height: 0,
                                                    indent: 80,
                                                    endIndent: 80,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              // Container(
                              //   decoration: const BoxDecoration(
                              //     color: Color.fromARGB(117, 160, 159, 159),
                              //     border: Border(
                              //       top: BorderSide(color: Colors.black),
                              //       left: BorderSide(color: Colors.black),
                              //       right: BorderSide(color: Colors.black),
                              //       bottom: BorderSide(color: Colors.black),
                              //     ),
                              //   ),
                              //   height: 340,
                              //   width: 340,
                              //   child: const Center(
                              //     child: Text(
                              //       "Sales Graph",
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Divider(
                                height: 0,
                                indent: 45,
                                endIndent: 45,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    "Recent Orders",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              _recentReceivedOrders.isEmpty
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: Image.asset(
                                            "lib/assets/images/order1.png",
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 70,
                                          width: double.maxFinite,
                                          child: Center(
                                            child: Text(
                                              "No new recent orders",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _recentReceivedOrders.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            // var orderDetailUrl = Uri.https(authority,
                                            //     'api/common/getOrderDetails', {
                                            //   "id": _recentReceivedOrders[index].orderId
                                            // });
                                            // http.get(orderDetailUrl, headers: {
                                            //   'Content-Type': 'application/json'
                                            // }).then((response) {
                                            //   var activeOrdersUrlResp =
                                            //       json.decode(response.body);
                                            //   var orderDetails =
                                            //       activeOrdersUrlResp['orderDetails'];
                                            //   var orderDetail = Order(
                                            //     orderId: orderDetails[0]["_id"],
                                            //     productId: orderDetails[0]
                                            //         ["productDetails"][0]["productName"],
                                            //     minNoLot: orderDetails[0]
                                            //         ["productDetails"][0]["minNoLot"],
                                            //     quantityPerLot: orderDetails[0]
                                            //             ["productDetails"][0]
                                            //         ["quantityPerLot"],
                                            //     productName: orderDetails[0]
                                            //             ["productDetails"][0]
                                            //         ["productName"],
                                            //     paymentMode: orderDetails[0]
                                            //         ["paymentMode"],
                                            //     halfPaymentDone: orderDetails[0]
                                            //         ["isBuyerClosed"],
                                            //     fullPaymentDone: orderDetails[0]
                                            //         ["isBuyerClosed"],
                                            //     basePrice: orderDetails[0]["dealPrice"],
                                            //     dealPrice: orderDetails[0]["dealPrice"],
                                            //     orderQtyLots: orderDetails[0]
                                            //         ["orderQtyLots"],
                                            //     orderValue: orderDetails[0]
                                            //         ["orderValue"],
                                            //     isOrderAccepted: orderDetails[0]
                                            //         ["isOrderAccepted"],
                                            //     isClosed: orderDetails[0]["isClosed"],
                                            //     closedOn: DateTime.tryParse(
                                            //         orderDetails[0]["closedOn"]
                                            //             .toString()),
                                            //     requiredOnOrBefore: DateTime.parse(
                                            //         orderDetails[0]
                                            //             ["requiredOnOrBefore"]),
                                            //     expectingResponseBefore: DateTime.parse(
                                            //         orderDetails[0]
                                            //             ["expectingResponseBefore"]),
                                            //     recievedOn: DateTime.parse(
                                            //         orderDetails[0]["createdAt"]),
                                            //     productImages: orderDetails[0]
                                            //             ["productDetails"][0]
                                            //         ["productImages"],
                                            //     dealerId: orderDetails[0]
                                            //         ["buyerDetails"][0]["_id"],
                                            //     dealerMobile: orderDetails[0]
                                            //         ["buyerDetails"][0]["mobile"],
                                            //     dealerName: orderDetails[0]
                                            //         ["buyerDetails"][0]["userName"],
                                            //     quantityUnit: orderDetails[0]
                                            //             ["productDetails"][0]
                                            //         ["quantityUnit"],
                                            //     buyerClosedOn: DateTime.parse(
                                            //         orderDetails[0]["buyerClosedOn"]),
                                            //     isBuyerClosed: orderDetails[0]
                                            //         ["isBuyerClosed"],
                                            //     isSellerClosed: orderDetails[0]
                                            //         ["isSellerClosed"],
                                            //     sellerClosedOn: DateTime.parse(
                                            //         orderDetails[0]["sellerClosedOn"]),
                                            //   );
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return SellerOrderDetailScreen(
                                                    orderId:
                                                        _recentReceivedOrders[
                                                                index]
                                                            .orderId,
                                                    refreshFunc: _onRefresh,
                                                  );
                                                },
                                              ),
                                            );
                                            // });
                                          },
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 35),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color
                                                                    .fromARGB(
                                                                117,
                                                                160,
                                                                159,
                                                                159),
                                                            // border: Border(
                                                            //   top: BorderSide(
                                                            //     width: 0.5,
                                                            //     color: Colors.black,
                                                            //   ),
                                                            //   left: BorderSide(
                                                            //     width: 0.5,
                                                            //     color: Colors.black,
                                                            //   ),
                                                            //   right: BorderSide(
                                                            //     width: 0.5,
                                                            //     color: Colors.black,
                                                            //   ),
                                                            //   bottom: BorderSide(
                                                            //     width: 0.5,
                                                            //     color: Colors.black,
                                                            //   ),
                                                            // ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          height: 75,
                                                          width: 75,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            child:
                                                                Image.network(
                                                              _recentReceivedOrders[
                                                                      index]
                                                                  .productImages[0],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${_recentReceivedOrders[index].productName} @ ${_recentReceivedOrders[index].dealPrice}/${_recentReceivedOrders[index].quantityUnit}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   "Quote price : ${_recentReceivedOrders[index].dealPrice}/${_topProductsSoldList[index].quantityUnit}",
                                                            //   style: const TextStyle(
                                                            //     fontSize: 15,
                                                            //   ),
                                                            // ),
                                                            Text(
                                                              "Buyer : ${_recentReceivedOrders[index].dealerName}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Respond by : ${_recentReceivedOrders[index].expectingResponseBefore.toLocal().day}/${_recentReceivedOrders[index].expectingResponseBefore.toLocal().month}/${_recentReceivedOrders[index].expectingResponseBefore.toLocal().year}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              const Divider(
                                                height: 0,
                                                indent: 80,
                                                endIndent: 80,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                              // Container(
                              //   decoration: const BoxDecoration(
                              //     color: Color.fromARGB(117, 160, 159, 159),
                              //     border: Border(
                              //       top: BorderSide(color: Colors.black),
                              //       left: BorderSide(color: Colors.black),
                              //       right: BorderSide(color: Colors.black),
                              //       bottom: BorderSide(color: Colors.black),
                              //     ),
                              //   ),
                              //   height: 170,
                              //   width: 340,
                              //   child: const Center(
                              //     child: Text(
                              //       "Recent Orders",
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
