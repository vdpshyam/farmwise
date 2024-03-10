import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../../models/order.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';
import '../user_public_profile_screen.dart';
import 'buyer_edit_order_screen.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  const BuyerOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.refreshOrdersListFunc,
  });

  final String orderId;
  final Function refreshOrdersListFunc;

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
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
            expectingResponseBefore = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]
                    ["expectingResponseBefore"]);
            recievedOn = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]["createdAt"]);
            updatedAt = DateTime.parse(
                getOrderDetailsResp["orderDetails"][0]["updatedAt"]);
            orderQtyLots =
                getOrderDetailsResp["orderDetails"][0]["orderQtyLots"];
            isBuyerClosed =
                getOrderDetailsResp["orderDetails"][0]["isBuyerClosed"];
            isSellerClosed =
                getOrderDetailsResp["orderDetails"][0]["isSellerClosed"];
            if (getOrderDetailsResp["orderDetails"][0]["sellerDetails"].length >
                0) {
              dealerId = getOrderDetailsResp["orderDetails"][0]["sellerDetails"]
                  [0]["_id"];
              dealerName = getOrderDetailsResp["orderDetails"][0]
                  ["sellerDetails"][0]["userName"];
              dealerMobile = getOrderDetailsResp["orderDetails"][0]
                  ["sellerDetails"][0]["mobile"];
            }
            if (getOrderDetailsResp["orderDetails"][0]["productDetails"]
                    .length >
                0) {
              productId = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["_id"];
              productName = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["productName"];
              basePrice = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["basePrice"];
              quantityPerLot = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["quantityPerLot"];
              quantityUnit = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["quantityUnit"];
              minNoLot = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["minNoLot"];
              productImages = getOrderDetailsResp["orderDetails"][0]
                  ["productDetails"][0]["productImages"];
            }
          }
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void cancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Cancel order?",
          ),
          content: const Text("This action can not be undone."),
          actions: [
            TextButton(
              child: const Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Cancel order",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(PageRouteBuilder(
                    barrierColor: const Color.fromARGB(91, 158, 158, 158),
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return const LoadingScreen();
                    }));
                var rejectOrderUrl = Uri.https(
                  authority,
                  'api/common/rejectOrder',
                );
                http
                    .delete(
                  rejectOrderUrl,
                  headers: {
                    'Authorization': loggedInUserAuthToken,
                    'Content-Type': 'application/json'
                  },
                  body: json.encode(
                    {
                      "orderId": widget.orderId,
                    },
                  ),
                )
                    .then((response) {
                  Navigator.of(context).pop();
                  if (response.statusCode == 200) {
                    var rejectOrderResp = json.decode(response.body);
                    if (rejectOrderResp["message"] ==
                        "Order rejected successfully") {
                      Navigator.of(context).pop();
                      widget.refreshOrdersListFunc();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Order cancelled.'),
                          action: SnackBarAction(
                            label: 'okay',
                            onPressed: () {},
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Order cancelled.',
                          ),
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
                        content: const Text(
                          'Could not cancel Try again later.',
                        ),
                        action: SnackBarAction(
                          label: 'okay',
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void markAsCompleteActiveOrder(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    var markAsCompleteUrl = Uri.https(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    // if (isSellerClosed) {
    //   markAsCompleteData = json.encode(
    //     {
    //       "id": orderId,
    //       "halfPaymentDone": true,
    //       "fullPaymentDone": true,
    //       "isClosed": true,
    //       "buyerClosedOn": DateTime.now().toUtc().toString(),
    //       "isBuyerClosed": true,
    //       // "isSellerClosed": true,
    //       // "sellerClosedOn":
    //       //     DateTime.now().toUtc().toString(),
    //       "closedOn": DateTime.now().toUtc().toString()
    //     },
    //   );
    // } else {
    markAsCompleteData = json.encode({
      "id": widget.orderId,
      "halfPaymentDone": true,
      "fullPaymentDone": true,
      "isClosed": false,
      "buyerClosedOn": DateTime.now().toUtc().toString(),
      "isBuyerClosed": true,
      // "isSellerClosed": false,
      // "sellerClosedOn": DateTime.now().toUtc().toString(),
      "closedOn": DateTime.now().toUtc().toString()
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
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var markAsCompleteResp = json.decode(response.body);
        if (markAsCompleteResp["message"] == "Order updated") {
          // if (isSellerClosed) {
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
            isBuyerClosed = true;
            isSellerClosed = false;
          });
          widget.refreshOrdersListFunc();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Order flagged.The order will be marked as complete when seller approves.',
              ),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
          // }
        }
      }
    });
  }

  void markAsCompleteFlaggedOrder(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    var markAsCompleteUrl = Uri.https(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    markAsCompleteData = json.encode(
      {
        "id": widget.orderId,
        "halfPaymentDone": true,
        "fullPaymentDone": true,
        "isClosed": true,
        "buyerClosedOn": DateTime.now().toUtc().toString(),
        "isBuyerClosed": true,
        // "isSellerClosed": true,
        // "sellerClosedOn":
        //     DateTime.now().toUtc().toString(),
        "closedOn": DateTime.now().toUtc().toString()
      },
    );
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
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var markAsCompleteResp = json.decode(response.body);
        if (markAsCompleteResp["message"] == "Order updated") {
          widget.refreshOrdersListFunc();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order marked as complete.'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
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
    orderDetailsUrl = Uri.https(authority, 'api/common/getOrderDetails', {
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
                      height: 180,
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Base price : $basePrice/$quantityUnit",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Quote price : $dealPrice/$quantityUnit",
                              style: const TextStyle(fontSize: 16),
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              "Required on or before : ${requiredOnOrBefore?.toLocal().day}/${requiredOnOrBefore?.toLocal().month}/${requiredOnOrBefore?.toLocal().year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 15.0),
                            child: Text(
                              "Seller Details :",
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
                                const Text(
                                  "Name : ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return UserPublicProfileScreen(
                                          userId: dealerId,
                                        );
                                      },
                                    ));
                                  },
                                  child: Text(
                                    dealerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 27, 152, 255),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (isOrderAccepted)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                "Phone: $dealerMobile",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          // const Padding(
                          //   padding: EdgeInsets.only(bottom: 5.0),
                          //   child: Text(
                          //     "Comments from Buyer: ",
                          //     style: TextStyle(fontSize: 20),
                          //   ),
                          // ),
                          // const Text(
                          //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris sapien orci, feugiat id dui sit amet, interdum",
                          //   textAlign: TextAlign.justify,
                          //   style: TextStyle(fontSize: 20),
                          // ),
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
                            context: context
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
                                    cancelOrder(context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Color.fromARGB(255, 252, 96, 85),
                                  ),
                                  label: const Text(
                                    "Cancel order",
                                    style: TextStyle(
                                      fontSize: 17,
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BuyerEditOrderScreen(
                                            orderId: orderId,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_note,
                                  ),
                                  label: const Text(
                                    "Edit",
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
                          if (isOrderAccepted && !isClosed)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isOrderAccepted &&
                                    isBuyerClosed &&
                                    !isSellerClosed)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 236, 216, 31),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 7),
                                    child: const Text(
                                      "Flagged: Waiting for Seller response.",
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
                                    !isBuyerClosed &&
                                    isSellerClosed)
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
  required BuildContext context
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
        milestoneSubtitle: "Your order is placed.",
        updatedAt: updatedAt,
        isOrderRejected: isOrderRejected,
        context: context
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
          milestoneSubtitle: "Your order is accepted by the seller.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
          context: context
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
          milestoneSubtitle: "Your order is currently in progress.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
          context: context
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
          milestone: "Order Flagged",
          isCurrent: isOrderAccepted &&
              !isClosed &&
              (!isSellerClosed ^ !isBuyerClosed),
          milestoneSubtitle: (!isSellerClosed && isBuyerClosed)
              ? "You marked this order as complete. Waiting for seller's response."
              : "Seller marked this order as complete. Waiting for your response.",
          updatedAt: updatedAt,
          isOrderRejected: isOrderRejected,
          context: context
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
        milestone: isOrderRejected ? "Order rejected" : "Order Closed",
        isCurrent: isOrderRejected ? true : isClosed,
        milestoneSubtitle: "This Order is closed",
        updatedAt: updatedAt,
        isOrderRejected: isOrderRejected,
        context: context
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
  required BuildContext context
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.9,
    child: Row(
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
                    "on: ${updatedAt!.toLocal().day}/${updatedAt.toLocal().month}/${updatedAt.toLocal().year}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            if (isCurrent)
              SizedBox(
                width: 260,
                child: Text(
                  milestoneSubtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    ),
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
