import 'package:flutter/material.dart';

class BuyerOrdersHistoryOrderItemWidget extends StatelessWidget {
  const BuyerOrdersHistoryOrderItemWidget(
      {super.key,
      required this.productName,
      required this.quantityUnit,
      required this.sellerName,
      required this.sellerMobile,
      required this.productImageUrl,
      required this.dealPrice,
      required this.orderQtyLots,
      required this.totalOrdervalue,
      required this.receivedOn,
      required this.respondedOn,
      required this.closedOn,
      required this.isBuyerClosed,
      required this.isClosed,
      required this.isOrderAccepted,
      required this.isSellerClosed});

  final String productName,
      quantityUnit,
      sellerName,
      sellerMobile,
      productImageUrl;
  final int dealPrice, orderQtyLots, totalOrdervalue;
  final DateTime receivedOn, respondedOn, closedOn;
  final bool isBuyerClosed, isClosed, isOrderAccepted, isSellerClosed;
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
                      color: const Color.fromARGB(117, 160, 159, 159),
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
                      borderRadius: BorderRadius.circular(7),
                    ),
                    height: 105,
                    width: 105,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        productImageUrl,
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
                        productName,
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Price : $dealPrice/$quantityUnit",
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        "Lots   : $orderQtyLots",
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  if (!isBuyerClosed &&
                      !isOrderAccepted &&
                      !isSellerClosed &&
                      isClosed)
                    SizedBox(
                      height: 115,
                      width: 77,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            child: const Text(
                              "Rejected",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Placed on",
                      //   style: TextStyle(
                      //     fontSize: 19,
                      //   ),
                      // ),
                      // Text(
                      //   "Closed on",
                      //   style: TextStyle(
                      //     fontSize: 21,
                      //   ),
                      // ),
                      Text(
                        "Closed on",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        "Seller",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      // Text(
                      //   "Seller Ph.",
                      //   style: TextStyle(
                      //     fontSize: 19,
                      //   ),
                      // ),
                      Text(
                        "Order value",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Column(
                    children: [
                      // Text(
                      //   " : ",
                      //   style: TextStyle(
                      //     fontSize: 19,
                      //   ),
                      // ),
                      // Text(
                      //   " : ",
                      //   style: TextStyle(
                      //     fontSize: 21,
                      //   ),
                      // ),
                      Text(
                        " : ",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      // Text(
                      //   " : ",
                      //   style: TextStyle(
                      //     fontSize: 19,
                      //   ),
                      // ),
                      Text(
                        " : ",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        " : ",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "${receivedOn.toLocal().day}/${receivedOn.toLocal().month}/${receivedOn.toLocal().year}",
                      //   style: const TextStyle(fontSize: 19),
                      // ),
                      // Text(
                      //   "${respondedOn.toLocal().day}/${respondedOn.toLocal().month}/${respondedOn.toLocal().year}",
                      //   style: const TextStyle(fontSize: 21),
                      // ),
                      Text(
                        "${closedOn.toLocal().day}/${closedOn.toLocal().month}/${closedOn.toLocal().year}",
                        style: const TextStyle(fontSize: 19),
                      ),
                      Text(
                        sellerName,
                        style: const TextStyle(fontSize: 19),
                      ),
                      // Text(
                      //   sellerMobile,
                      //   style: const TextStyle(fontSize: 19),
                      // ),
                      Text(
                        "Rs.$totalOrdervalue",
                        style: const TextStyle(fontSize: 19),
                      ),
                    ],
                  )
                ],
              ),
              // Text(
              //   "Placed on : ${receivedOn.toLocal().day}/${receivedOn.toLocal().month}/${receivedOn.toLocal().year}",
              //   style: const TextStyle(
              //     fontSize: 21,
              //   ),
              // ),
              // Text(
              //   "Closed on : ${closedOn.toLocal().day}/${closedOn.toLocal().month}/${closedOn.toLocal().year}",
              //   style: const TextStyle(
              //     fontSize: 21,
              //   ),
              // ),
              // Text(
              //   "Seller : $sellerName",
              //   style: const TextStyle(
              //     fontSize: 21,
              //   ),
              // ),
              // Text(
              //   "Seller Ph : $sellerMobile",
              //   style: const TextStyle(
              //     fontSize: 21,
              //   ),
              // ),
              // Text(
              //   "Total Order Value : Rs.$totalOrdervalue",
              //   style: const TextStyle(
              //     fontSize: 21,
              //   ),
              // ),
              const SizedBox(
                height: 10,
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
