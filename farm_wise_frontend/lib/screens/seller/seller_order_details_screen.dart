import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../../models/order.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';
import '../user_public_profile_screen.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.refreshFunc,
  });

  final String orderId;
  final Function refreshFunc;

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  late Uri orderDetailsUrl;
  bool isLoading = true;

  late String orderId,
      dealerId,
      productId,
      paymentMode,
      productName,
      dealerName,
      dealerMobile,
      quantityUnit;
  late int basePrice,
      dealPrice,
      orderQtyLots,
      orderValue,
      minNoLot,
      quantityPerLot;
  late bool isOrderAccepted,
      isClosed,
      halfPaymentDone,
      fullPaymentDone,
      isSellerClosed,
      isBuyerClosed;
  late DateTime? requiredOnOrBefore,
      expectingResponseBefore,
      recievedOn,
      updatedAt;
  late List productImages;

  void getOrderDetails() {
    http.get(
      orderDetailsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getOrderDetailsResp = json.decode(response.body);
        if (getOrderDetailsResp["message"] == "Orders details recieved") {
          if (getOrderDetailsResp["orderDetails"].length > 0) {
            orderId = getOrderDetailsResp["orderDetails"][0]["_id"];
            dealPrice = getOrderDetailsResp["orderDetails"][0]["dealPrice"];
            orderValue = getOrderDetailsResp["orderDetails"][0]["orderValue"];
            isOrderAccepted =
                getOrderDetailsResp["orderDetails"][0]["isOrderAccepted"];
            paymentMode = getOrderDetailsResp["orderDetails"][0]["paymentMode"];
            isClosed = getOrderDetailsResp["orderDetails"][0]["isClosed"];
            requiredOnOrBefore = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]["requiredOnOrBefore"]);
            updatedAt = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]["updatedAt"]);
            expectingResponseBefore = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]
                    ["expectingResponseBefore"]);
            recievedOn = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]["createdAt"]);
            orderQtyLots =
                getOrderDetailsResp["orderDetails"][0]["orderQtyLots"];
            isBuyerClosed =
                getOrderDetailsResp["orderDetails"][0]["isBuyerClosed"];
            isSellerClosed =
                getOrderDetailsResp["orderDetails"][0]["isSellerClosed"];
            dealerId = getOrderDetailsResp["orderDetails"][0]["buyerDetails"][0]
                ["_id"];
            dealerName = getOrderDetailsResp["orderDetails"][0]["buyerDetails"]
                [0]["userName"];
            dealerMobile = getOrderDetailsResp["orderDetails"][0]
                ["buyerDetails"][0]["mobile"];
            productId = getOrderDetailsResp["orderDetails"][0]["productDetails"]
                [0]["_id"];
            productName = getOrderDetailsResp["orderDetails"][0]
                ["productDetails"][0]["productName"];
            basePrice = getOrderDetailsResp["orderDetails"][0]["productDetails"]
                [0]["basePrice"];
            quantityPerLot = getOrderDetailsResp["orderDetails"][0]
                ["productDetails"][0]["quantityPerLot"];
            quantityUnit = getOrderDetailsResp["orderDetails"][0]
                ["productDetails"][0]["quantityUnit"];
            minNoLot = getOrderDetailsResp["orderDetails"][0]["productDetails"]
                [0]["minNoLot"];
            productImages = getOrderDetailsResp["orderDetails"][0]
                ["productDetails"][0]["productImages"];
          }
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void rejectOrder(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject order?"),
          content: const Text(
            "Once a order is rejected, it can not be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(PageRouteBuilder(
                    barrierColor: const Color.fromARGB(91, 158, 158, 158),
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return const LoadingScreen();
                    }));
                var rejectOrderUrl = Uri.http(
                  authority,
                  'api/common/updateOrderDetails',
                );
                http
                    .put(
                  rejectOrderUrl,
                  headers: {
                    'Authorization': loggedInUserAuthToken,
                    'Content-Type': 'application/json'
                  },
                  body: json.encode(
                    {
                      "id": orderId,
                      "halfPaymentDone": false,
                      "fullPaymentDone": false,
                      "isClosed": true,
                      "closedOn": DateTime.now().toUtc().toString()
                    },
                  ),
                )
                    .then((response) {
                  Navigator.of(context).pop();
                  if (response.statusCode == 200) {
                    var rejectOrderResp = json.decode(response.body);
                    if (rejectOrderResp["message"] == "Order updated") {
                      Navigator.of(context).pop();
                      widget.refreshFunc();
                      final snackBar = SnackBar(
                        content: const Text('Order succesfully rejected.'),
                        action: SnackBarAction(
                          label: 'okay',
                          onPressed: () {},
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              "Could not reject ",
                            ),
                            content: const Text(
                              "Please try again later",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {},
                                child: const Text("okay"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            "Something went wrong.",
                          ),
                          content: const Text(
                            "Please try again later",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {},
                              child: const Text("okay"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: const Text(
                "Reject order",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void acceptOrder(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        },
      ),
    );
    var acceptOrderUrl = Uri.http(
      authority,
      'api/common/updateOrderDetails',
    );
    http
        .put(
      acceptOrderUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
      body: json.encode(
        {
          "id": orderId,
          "isOrderAccepted": true,
          "sellerId": loggedInUserDetails.userId,
          "buyerId": dealerId,
        },
      ),
    )
        .then((response) {
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var acceptOrderResp = json.decode(response.body);
        if (acceptOrderResp["message"] == "Order updated") {
          widget.refreshFunc();
          _onRefresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order accepted.'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not accept order.Try again later.'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong.Try again later.'),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  void markAsCompleteActiveOrder(BuildContext context) {
    var markAsCompleteUrl = Uri.http(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    // if (order.isBuyerClosed) {
    //   markAsCompleteData = json.encode(
    //     {
    //       "id": order.orderId,
    //       "halfPaymentDone": true,
    //       "fullPaymentDone": true,
    //       "isClosed": true,
    //       // "buyerClosedOn":
    //       //     DateTime.now().toUtc().toString(),
    //       // "isBuyerClosed": true,
    //       "isSellerClosed": true,
    //       "sellerClosedOn": DateTime.now().toUtc().toString(),
    //       "closedOn": DateTime.now().toUtc().toString()
    //     },
    //   );
    // } else {
    markAsCompleteData = json.encode({
      "id": orderId,
      "halfPaymentDone": true,
      "fullPaymentDone": true,
      "isClosed": false,
      // "buyerClosedOn":
      //     DateTime.now().toUtc().toString(),
      // "isBuyerClosed": false,
      "isSellerClosed": true,
      "sellerClosedOn": DateTime.now().toUtc().toString(),
      // "closedOn": DateTime.now().toUtc().toString()
    });
    // }
    http
        .put(
      markAsCompleteUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
      body: markAsCompleteData,
    )
        .then((response) {
      if (response.statusCode == 200) {
        var markAsCompleteResp = json.decode(response.body);
        if (markAsCompleteResp["message"] == "Order updated") {
          // if (order.isBuyerClosed) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: const Text('Order marked as complete.'),
          //       action: SnackBarAction(
          //         label: 'okay',
          //         onPressed: () {},
          //       ),
          //     ),
          //   );
          // } else {
          setState(() {
            isOrderAccepted = true;
            isBuyerClosed = false;
            isSellerClosed = true;
          });
          widget.refreshFunc();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Order flagged.The order will be marked as complete when buyer approves.',
              ),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        }
      }
      // }
    });
  }

  void markAsCompleteFlaggedOrder(BuildContext context) {
    var markAsCompleteUrl = Uri.http(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    // if (order.isBuyerClosed) {
    markAsCompleteData = json.encode(
      {
        "id": orderId,
        "halfPaymentDone": true,
        "fullPaymentDone": true,
        "isClosed": true,
        // "buyerClosedOn":
        //     DateTime.now().toUtc().toString(),
        // "isBuyerClosed": true,
        "isSellerClosed": true,
        "sellerClosedOn": DateTime.now().toUtc().toString(),
        "closedOn": DateTime.now().toUtc().toString()
      },
    );
    // } else {
    //   markAsCompleteData = json.encode({
    //     "id": order.orderId,
    //     "halfPaymentDone": true,
    //     "fullPaymentDone": true,
    //     "isClosed": false,
    //     // "buyerClosedOn":
    //     //     DateTime.now().toUtc().toString(),
    //     // "isBuyerClosed": false,
    //     "isSellerClosed": true,
    //     "sellerClosedOn": DateTime.now().toUtc().toString(),
    //     "closedOn": DateTime.now().toUtc().toString()
    //   });
    // }
    http
        .put(
      markAsCompleteUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
      body: markAsCompleteData,
    )
        .then((response) {
      if (response.statusCode == 200) {
        var markAsCompleteResp = json.decode(response.body);
        if (markAsCompleteResp["message"] == "Order updated") {
          // if (order.isBuyerClosed) {
          widget.refreshFunc();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order marked as complete.'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
          // } else {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: const Text(
          //           'Order flagged.The order will be marked as complete when buyer approves.'),
          //       action: SnackBarAction(
          //         label: 'okay',
          //         onPressed: () {},
          //       ),
          //     ),
          //   );
          // }
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getOrderDetails();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    orderDetailsUrl = Uri.http(authority, 'api/farmer/getOrderDetails', {
      "id": widget.orderId,
    });
    getOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            "Order#${widget.orderId}",
          ),
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(81, 160, 159, 159),
                      ),
                      width: double.maxFinite,
                      height: 263,
                      child: Image.network(
                        productImages[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Item Name : $productName",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Quote price : $dealPrice/$quantityUnit",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "No. of Lot(s) : $orderQtyLots",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Total Price : Rs.$orderValue",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Required on or before : ${requiredOnOrBefore?.toLocal().day}/${requiredOnOrBefore?.toLocal().month}/${requiredOnOrBefore?.toLocal().year}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Expecting response by : ${expectingResponseBefore?.toLocal().day}/${expectingResponseBefore?.toLocal().month}/${expectingResponseBefore?.toLocal().year}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 15.0),
                            child: Text(
                              "Buyer details :",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Name",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (isOrderAccepted)
                                      const Text(
                                        "Mobile",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      ":",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    if (isOrderAccepted)
                                      const Text(
                                        ":",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return UserPublicProfileScreen(
                                                userId: dealerId,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Text(
                                        dealerName,
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.blue),
                                      ),
                                    ),
                                    if (isOrderAccepted)
                                      Text(
                                        dealerMobile,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Order Status :",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          timeLineDecorationGenerator(
                            isBuyerClosed: isBuyerClosed,
                            isClosed: isClosed,
                            isOrderAccepted: isOrderAccepted,
                            isSellerClosed: isSellerClosed,
                            updatedAt: updatedAt,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          if (!isOrderAccepted &&
                              !(!isOrderAccepted && isClosed))
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    rejectOrder(context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Color.fromARGB(255, 252, 96, 85),
                                  ),
                                  label: const Text(
                                    "Decline",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 252, 96, 85),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    acceptOrder(context);
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    "Accept",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isOrderAccepted &&
                                  !isBuyerClosed &&
                                  isSellerClosed)
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 236, 216, 31),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  child: const Text(
                                    "Flagged: Waiting for buyer response.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              if (isOrderAccepted &&
                                  !isBuyerClosed &&
                                  !isSellerClosed)
                                TextButton.icon(
                                  onPressed: () {
                                    // if (order.isOrderAccepted) {
                                    markAsCompleteActiveOrder(context);
                                    // } else {
                                    //   acceptOrder(context);
                                    // }
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    // order.isOrderAccepted
                                    //     ?
                                    "Mark as completed",
                                    // : "Accept",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              if (isOrderAccepted &&
                                  isBuyerClosed &&
                                  !isSellerClosed)
                                TextButton.icon(
                                  onPressed: () {
                                    // if (order.isOrderAccepted) {
                                    markAsCompleteFlaggedOrder(context);
                                    // } else {
                                    //   acceptOrder(context);
                                    // }
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    // order.isOrderAccepted
                                    //     ?
                                    "Mark as completed",
                                    // : "Accept",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

Widget timeLineDecorationGenerator({
  required bool isOrderAccepted,
  required bool isSellerClosed,
  required bool isBuyerClosed,
  required bool isClosed,
  required DateTime? updatedAt,
}) {
  bool isOrderRejected = !isOrderAccepted && isClosed;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      timeLineDecorationCircleGenerator(
        isMilestoneReached: true,
        milestone: "Order Placed",
        isCurrent:
            !isOrderAccepted && !isSellerClosed && !isBuyerClosed && !isClosed,
        milestoneSubtitle: "Order is placed.",
        updatedAt: updatedAt,
        isOrderRejected: isOrderRejected,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 13),
        child: timeLineDecorationLineGenerator(),
      ),
      if (!isOrderRejected)
        timeLineDecorationCircleGenerator(
          isMilestoneReached: isOrderAccepted,
          milestone: "Order accepted",
          isCurrent: false,
          milestoneSubtitle: "You accepted this order.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
        ),
      if (!isOrderRejected)
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: timeLineDecorationLineGenerator(),
        ),
      if (!isOrderRejected)
        timeLineDecorationCircleGenerator(
          isMilestoneReached: isOrderAccepted,
          milestone: "Order active",
          isCurrent:
              isOrderAccepted && !isSellerClosed && !isBuyerClosed && !isClosed,
          milestoneSubtitle: "This order is currently in progress.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
        ),
      if (!isOrderRejected)
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: timeLineDecorationLineGenerator(),
        ),
      if (!isOrderRejected)
        timeLineDecorationCircleGenerator(
          isMilestoneReached: (isOrderAccepted &&
                  (!isSellerClosed ^ !isBuyerClosed)) ||
              (isOrderAccepted && isSellerClosed && isBuyerClosed && isClosed),
          milestone: "Order Completed",
          isCurrent: isOrderAccepted &&
              !isClosed &&
              (!isSellerClosed ^ !isBuyerClosed),
          milestoneSubtitle: (isSellerClosed && !isBuyerClosed)
              ? "You marked this order as complete. Waiting for buyer's response."
              : "Buyer marked this order as complete. Waiting for your response.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
        ),
      if (!isOrderRejected)
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: timeLineDecorationLineGenerator(),
        ),
      timeLineDecorationCircleGenerator(
        isMilestoneReached: isOrderRejected
            ? true
            : isOrderAccepted && isSellerClosed && isBuyerClosed && isClosed,
        milestone: "Order Closed",
        isCurrent: isClosed,
        milestoneSubtitle: "This Order is closed",
        updatedAt: updatedAt,
        isOrderRejected: isOrderRejected,
      ),
    ],
  );
}

Widget timeLineDecorationCircleGenerator({
  required bool isMilestoneReached,
  required String milestone,
  required bool isCurrent,
  required bool isOrderRejected,
  required String milestoneSubtitle,
  required DateTime? updatedAt,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 1.0),
        child: Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: isMilestoneReached
                ? isOrderRejected
                    ? Colors.red
                    : const Color.fromARGB(159, 51, 118, 53)
                : null,
            border: Border.all(
              color: const Color.fromARGB(110, 51, 118, 53),
              width: isMilestoneReached ? 0 : 2.5,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: isMilestoneReached
              ? const Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                milestone,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: isMilestoneReached ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              if (isCurrent)
                Text(
                  "on: ${updatedAt!.toLocal().day}/${updatedAt.toLocal().month}${updatedAt.toLocal().year}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          if (isCurrent)
            SizedBox(
              width: 315,
              child: Text(
                milestoneSubtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    ],
  );
}

Widget timeLineDecorationLineGenerator() {
  return Container(
    height: 30,
    width: 0,
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(
            color: Color.fromARGB(255, 51, 118, 53), style: BorderStyle.solid),
      ),
    ),
  );
}
