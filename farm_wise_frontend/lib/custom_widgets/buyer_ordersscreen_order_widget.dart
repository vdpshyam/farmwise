import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/buyer/buyer_edit_order_screen.dart';
import '../screens/loading_screen.dart';

class BuyerOrderscreenOrderWidget extends StatelessWidget {
  const BuyerOrderscreenOrderWidget({
    super.key,
    required this.order,
  });

  final Order order;

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
                var rejectOrderUrl = Uri.http(
                  authority,
                  'api/common/rejectOrder',
                );
                http
                    .delete(
                  rejectOrderUrl,
                  headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                  body: json.encode(
                    {
                      "orderId": order.orderId,
                    },
                  ),
                )
                    .then((response) {
                  Navigator.of(context).pop();
                  if (response.statusCode == 200) {
                    var rejectOrderResp = json.decode(response.body);
                    if (rejectOrderResp["message"] ==
                        "Order rejected successfully") {
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
                          'Could not cancel order.Try again later.',
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
    if (order.isSellerClosed) {
      markAsCompleteData = json.encode(
        {
          "id": order.orderId,
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
    } else {
      markAsCompleteData = json.encode({
        "id": order.orderId,
        "halfPaymentDone": true,
        "fullPaymentDone": true,
        "isClosed": false,
        "buyerClosedOn": DateTime.now().toUtc().toString(),
        "isBuyerClosed": true,
        // "isSellerClosed": false,
        // "sellerClosedOn": DateTime.now().toUtc().toString(),
        "closedOn": DateTime.now().toUtc().toString()
      });
    }
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
          if (order.isSellerClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Order marked as complete.'),
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
                    'Order flagged.The order will be marked as complete when seller approves.'),
                action: SnackBarAction(
                  label: 'okay',
                  onPressed: () {},
                ),
              ),
            );
          }
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
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(0, 160, 159, 159),
                      // border: Border(
                      //   top: BorderSide(color: Colors.black),
                      //   left: BorderSide(color: Colors.black),
                      //   right: BorderSide(color: Colors.black),
                      //   bottom: BorderSide(color: Colors.black),
                      // ),
                    ),
                    height: 115,
                    width: 115,
                    child: Image.network(
                      order.productImages[0],
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
                        order.productName,
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Price : ${order.dealPrice}/${order.quantityUnit}",
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        "Lots : ${order.orderQtyLots}",
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              (order.isOrderAccepted)
                  ? Text(
                      "Order value : ${order.orderValue}",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    )
                  : Text(
                      "Placed on : ${order.recievedOn?.toLocal().day}/${order.recievedOn?.toLocal().month}/${order.recievedOn?.toLocal().year}",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    ),
              (order.isOrderAccepted)
                  ? Text(
                      "Seller : ${order.dealerName}",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    )
                  : Text(
                      "Expecting response : ${order.expectingResponseBefore?.toLocal().day}/${order.expectingResponseBefore?.toLocal().month}/${order.expectingResponseBefore?.toLocal().year}",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (!order.isOrderAccepted)
                    TextButton.icon(
                      onPressed: () {
                        cancelOrder(context);
                      },
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Color.fromARGB(255, 252, 96, 85),
                      ),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 252, 96, 85),
                        ),
                      ),
                    ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  (order.isOrderAccepted &&
                          !order.isSellerClosed &&
                          order.isBuyerClosed)
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          child: const Text(
                            "Flagged: Waiting for seller response.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            if (!order.isOrderAccepted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return BuyerEditOrderScreen(
                                      orderId: order.orderId,
                                    );
                                  },
                                ),
                              );
                            } else if (order.isOrderAccepted) {
                              markAsComplete(context);
                            }
                          },
                          icon: order.isOrderAccepted
                              ? const Icon(
                                  Icons.check,
                                )
                              : const Icon(
                                  Icons.edit_note_outlined,
                                ),
                          label: Text(
                            order.isOrderAccepted
                                ? "Mark as completed"
                                : "Edit",
                            style: const TextStyle(
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
