import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../models/order.dart';
import '../providers/https_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/loading_screen.dart';
// import '../screens/loading_screen.dart';

class BuyerOrderScreenActiveOrderWidget extends StatefulWidget {
  const BuyerOrderScreenActiveOrderWidget({
    super.key,
    required this.order,
    // required this.updateOrdersListFunc,
  });

  final OrderScreenActiveOrderWidgetModel order;

  @override
  State<BuyerOrderScreenActiveOrderWidget> createState() =>
      _BuyerOrderScreenActiveOrderWidgetState();
}

class _BuyerOrderScreenActiveOrderWidgetState
    extends State<BuyerOrderScreenActiveOrderWidget> {
  // final Function updateOrdersListFunc;
  void markAsComplete(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    var markAsCompleteUrl = Uri.http(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    // if (order.isSellerClosed) {
    //   markAsCompleteData = json.encode(
    //     {
    //       "id": order.orderId,
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
      "id": widget.order.orderId,
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
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
      body: markAsCompleteData,
    )
        .then((response) {
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        var markAsCompleteResp = json.decode(response.body);
        if (markAsCompleteResp["message"] == "Order updated") {
          // if (order.isSellerClosed) {
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
            widget.order.isBuyerClosed = true;
            widget.order.isSellerClosed = false;
          });
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(54, 160, 159, 159),
                      // border: Border(
                      //   top: BorderSide(color: Colors.black),
                      //   left: BorderSide(color: Colors.black),
                      //   right: BorderSide(color: Colors.black),
                      //   bottom: BorderSide(color: Colors.black),
                      // ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 105,
                    width: 105,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        widget.order.productImages[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.productName,
                        style: const TextStyle(
                          fontSize: 17.5,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Price : ${widget.order.dealPrice}/${widget.order.quantityUnit}",
                        style: const TextStyle(
                          fontSize: 17.5,
                        ),
                      ),
                      Text(
                        "Lots : ${widget.order.orderQtyLots}",
                        style: const TextStyle(
                          fontSize: 17.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              // (order.isOrderAccepted)
              //     ?
              Text(
                "Total value : ${widget.order.orderValue}",
                style: const TextStyle(
                  fontSize: 17.5,
                ),
              ),
              // : Text(
              //     "Received on : ${order.recievedOn?.toLocal().day}/${order.recievedOn?.toLocal().month}/${order.recievedOn?.toLocal().year}",
              //     style: const TextStyle(
              //       fontSize: 21,
              //     ),
              //   ),
              // (order.isOrderAccepted)
              //     ?
              Text(
                "Seller : ${widget.order.dealerName}",
                style: const TextStyle(
                  fontSize: 17.5,
                ),
              ),
              // : Text(
              //     "Respond before : ${order.expectingResponseBefore?.toLocal().day}/${order.expectingResponseBefore?.toLocal().month}/${order.expectingResponseBefore?.toLocal().year}",
              //     style: const TextStyle(
              //       fontSize: 21,
              //     ),
              //   ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  // if (!order.isOrderAccepted)
                  //   TextButton.icon(
                  //     onPressed: () {
                  //       rejectOrder(context);
                  //     },
                  //     icon: const Icon(
                  //       Icons.cancel_outlined,
                  //       color: Color.fromARGB(255, 252, 96, 85),
                  //     ),
                  //     label: const Text(
                  //       "Decline",
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.normal,
                  //         color: Color.fromARGB(255, 252, 96, 85),
                  //       ),
                  //     ),
                  //   ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  (widget.order.isBuyerClosed && !widget.order.isSellerClosed)
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 236, 216, 31),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          child: const Text(
                            "Flagged: Waiting for seller's response.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            // if (order.isOrderAccepted) {
                            markAsComplete(context);
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
                              fontSize: 19,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          indent: 70,
          endIndent: 70,
        ),
      ],
    );
  }
}
