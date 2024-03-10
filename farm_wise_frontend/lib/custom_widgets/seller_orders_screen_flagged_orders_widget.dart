import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../models/order.dart';
import '../providers/https_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/user_details_provider.dart';

class SellerOrderScreenFlaggedOrderWidget extends StatelessWidget {
  const SellerOrderScreenFlaggedOrderWidget({
    super.key,
    required this.order,
    required this.updateFlaggedOrdersFunc,
  });

  final OrderScreenFlaggedOrderWidgetModel order;
  final Function updateFlaggedOrdersFunc;

  // void rejectOrder(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Reject order?"),
  //         content:
  //             const Text("Once a order is rejected, it can not be undone."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.of(context).push(PageRouteBuilder(
  //                   barrierColor: const Color.fromARGB(91, 158, 158, 158),
  //                   opaque: false,
  //                   pageBuilder: (BuildContext context, _, __) {
  //                     return const LoadingScreen();
  //                   }));
  //               var rejectOrderUrl = Uri.http(
  //                 authority,
  //                 'api/common/updateOrderDetails',
  //               );
  //               http
  //                   .put(
  //                 rejectOrderUrl,
  //                 headers: {'Content-Type': 'application/json'},
  //                 body: json.encode(
  //                   {
  //                     "id": order.orderId,
  //                     "halfPaymentDone": false,
  //                     "fullPaymentDone": false,
  //                     "buyerClosedOn": DateTime.now().toUtc().toString(),
  //                     "isBuyerClosed": false,
  //                     "isSellerClosed": false,
  //                     "sellerClosedOn": DateTime.now().toUtc().toString(),
  //                     "isClosed": true,
  //                     "closedOn": DateTime.now().toUtc().toString()
  //                   },
  //                 ),
  //               )
  //                   .then((response) {
  //                 Navigator.of(context).pop();
  //                 if (response.statusCode == 200) {
  //                   var rejectOrderResp = json.decode(response.body);
  //                   if (rejectOrderResp["message"] == "Order updated") {
  //                     final snackBar = SnackBar(
  //                       content: const Text('Order succesfully rejected.'),
  //                       action: SnackBarAction(
  //                         label: 'okay',
  //                         onPressed: () {},
  //                       ),
  //                     );
  //                     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //                   } else {
  //                     showDialog(
  //                       context: context,
  //                       builder: (context) {
  //                         return AlertDialog(
  //                           title: const Text(
  //                             "Could not reject order.",
  //                           ),
  //                           content: const Text(
  //                             "Please try again later",
  //                           ),
  //                           actions: [
  //                             TextButton(
  //                               onPressed: () {},
  //                               child: const Text("okay"),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     );
  //                   }
  //                 } else {
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) {
  //                       return AlertDialog(
  //                         title: const Text(
  //                           "Something went wrong.",
  //                         ),
  //                         content: const Text(
  //                           "Please try again later",
  //                         ),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () {},
  //                             child: const Text("okay"),
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   );
  //                 }
  //               });
  //             },
  //             child: const Text(
  //               "Reject order",
  //               style: TextStyle(
  //                 color: Colors.red,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void acceptOrder(BuildContext context) {
  //   Navigator.of(context).push(PageRouteBuilder(
  //       barrierColor: const Color.fromARGB(91, 158, 158, 158),
  //       opaque: false,
  //       pageBuilder: (BuildContext context, _, __) {
  //         return const LoadingScreen();
  //       }));
  //   var acceptOrderUrl = Uri.http(
  //     authority,
  //     'api/common/updateOrderDetails',
  //   );
  //   http
  //       .put(
  //     acceptOrderUrl,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(
  //       {
  //         "id": order.orderId,
  //         "isOrderAccepted": true,
  //       },
  //     ),
  //   )
  //       .then((response) {
  //     Navigator.of(context).pop();
  //     if (response.statusCode == 200) {
  //       var acceptOrderResp = json.decode(response.body);
  //       if (acceptOrderResp["message"] == "Order updated") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: const Text('Order accepted.'),
  //             action: SnackBarAction(
  //               label: 'okay',
  //               onPressed: () {},
  //             ),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: const Text('Could not accept order.Try again later.'),
  //             action: SnackBarAction(
  //               label: 'okay',
  //               onPressed: () {},
  //             ),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Something went wrong.Try again later.'),
  //           action: SnackBarAction(
  //             label: 'okay',
  //             onPressed: () {},
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  void markAsComplete(BuildContext context) {
    var markAsCompleteUrl = Uri.http(
      authority,
      'api/common/updateOrderDetails',
    );
    String markAsCompleteData;
    // if (order.isBuyerClosed) {
    markAsCompleteData = json.encode(
      {
        "id": order.orderId,
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
          updateFlaggedOrdersFunc(order.orderId);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(117, 160, 159, 159),
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
                          order.productImages[0],
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
                          order.productName,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Price : ${order.dealPrice}/${order.quantityUnit}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Lots : ${order.orderQtyLots}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // (order.isOrderAccepted)
              //     ?
              Text(
                "Total value : ${order.orderValue}",
                style: const TextStyle(
                  fontSize: 16,
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
                "Buyer : ${order.dealerName}",
                style: const TextStyle(
                  fontSize: 16,
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
                  // (order.isOrderAccepted &&
                  //         !order.isBuyerClosed &&
                  //         order.isSellerClosed)
                  //     ?
                  //     Container(
                  //         decoration: BoxDecoration(
                  //           color: Colors.red,
                  //           borderRadius: BorderRadius.circular(5),
                  //         ),
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 10, vertical: 7),
                  //         child: const Text(
                  //           "Flagged: Waiting for buyer response.",
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       )
                  // :
                  TextButton.icon(
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
        const Divider(
          height: 0,
          indent: 70,
          endIndent: 70,
        ),
      ],
    );
  }
}
