import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/providers/https_provider.dart';

// import '../models/product.dart';
import '../providers/products_list_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/seller/seller_edit_item_screen.dart';

class SellerListscreenItemWidget extends StatefulWidget {
  const SellerListscreenItemWidget(
      {super.key,
      required this.listedItemsScreenProduct,
      required this.updateListedItemFunc});

  final ListedItemsScreenProductModel listedItemsScreenProduct;
  final Function updateListedItemFunc;

  @override
  State<SellerListscreenItemWidget> createState() =>
      _SellerListscreenItemWidgetState();
}

class _SellerListscreenItemWidgetState
    extends State<SellerListscreenItemWidget> {
  late bool switchSelection;
  late Uri productUpdateUrl, productDeleteUrl, getOpenOrdersUrl;
  // int openOrders = 0;

// delete items
  void deleteItem() {
    if (widget.listedItemsScreenProduct.openOrders > 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Can not delete item."),
            content: const Text(
                "Can not delete an item when it has open orders.Please fulfill the orders or cancel the orders in order to delete the item.Alternatively, if you want to it not to appear for future search results for wholesalers, you can deactivate this item."),
            actions: [
              TextButton(
                child: const Text("okay"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Deactivate item"),
                onPressed: () {
                  http
                      .post(
                    productUpdateUrl,
                    headers: {
                      'Authorization': loggedInUserAuthToken,
                      'Content-Type': 'application/json'
                    },
                    body: json.encode(
                      {
                        "productId": widget.listedItemsScreenProduct.productId,
                        "availStatus": false,
                      },
                    ),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      var deactProdResp = json.decode(response.body);
                      if (deactProdResp["msg"] ==
                          "Product Updated Successfully") {
                        setState(() {
                          switchSelection = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item deactivated'),
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
                                'Could not deactivate item.Try again later.'),
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
                              'Something went wrong.Try again later.'),
                          action: SnackBarAction(
                            label: 'okay',
                            onPressed: () {},
                          ),
                        ),
                      );
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete item?"),
            content: const Text(
              "Once the item is deleted, it can't be undone.",
            ),
            actions: [
              TextButton(
                child: const Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  http
                      .post(
                    productDeleteUrl,
                    headers: {
                      'Authorization': loggedInUserAuthToken,
                      'Content-Type': 'application/json'
                    },
                    body: json.encode(
                      {
                        "productId": widget.listedItemsScreenProduct.productId,
                      },
                    ),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      var deleteUrlResp = json.decode(response.body);
                      if (deleteUrlResp["msg"] ==
                          "Product Removed successfully") {
                        widget.updateListedItemFunc(
                            widget.listedItemsScreenProduct.productId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item succesfully deleted.'),
                            action: SnackBarAction(
                              label: 'okay',
                              onPressed: () {
                                // Code to execute.
                              },
                            ),
                          ),
                        );
                        // showDialog(
                        //   context: context,
                        //   builder: (context) {
                        //     return AlertDialog(
                        //       title: const Text(
                        //         "",
                        //       ),
                        //       actions: [
                        //         TextButton(
                        //           child: const Text("okay"),
                        //           onPressed: () {
                        //             Navigator.of(context).pop();
                        //           },
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Could not delete item."),
                              content: const Text("Please try again later."),
                              actions: [
                                TextButton(
                                  child: const Text("okay"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
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
                            title: const Text("Something went wrong."),
                            content: const Text("Please try again later."),
                            actions: [
                              TextButton(
                                child: const Text("okay"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
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
  }

  // void getOpenOrders() {
  //   var getOenOrdersUrl = Uri.https(authority, 'api/farmer/getOpenOrders',
  //       {"productId": widget.product.productId});
  //   http.get(
  //     getOenOrdersUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ).then((response) {
  //     var getOpenOrdersResp = json.decode(response.body);
  //     if (response.statusCode == 200) {
  //       if (getOpenOrdersResp['message'] == "orders count found") {
  //         if (getOpenOrdersResp["ordersCount"].length > 0) {
  //           setState(() {
  //             openOrders = getOpenOrdersResp["ordersCount"][0]["openOrders"];
  //           });
  //         }
  //         // print("${widget.product.productName} : $openOrders : ${widget.product.productId}");
  //       }
  //       print(getOpenOrdersResp);
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    switchSelection = widget.listedItemsScreenProduct.availStatus;
    productUpdateUrl = Uri.https(
      authority,
      'api/farmer/updateproduct',
    );
    productDeleteUrl = Uri.https(
      authority,
      'api/farmer/deleteproduct',
    );
    // getOpenOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 35),
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
                  //   top: BorderSide(width: 0.5, color: Colors.black),
                  //   left: BorderSide(width: 0.5, color: Colors.black),
                  //   right: BorderSide(width: 0.5, color: Colors.black),
                  //   bottom: BorderSide(width: 0.5, color: Colors.black),
                  // ),
                  borderRadius: BorderRadius.circular(7),
                ),
                height: 105,
                width: 105,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    widget.listedItemsScreenProduct.productImages[0],
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
                    widget.listedItemsScreenProduct.productName,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Base Price : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${widget.listedItemsScreenProduct.basePrice} ${widget.listedItemsScreenProduct.quantityUnit}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Min. Lot(s) : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.listedItemsScreenProduct.minNoLot.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Quantity per Lot : ${widget.listedItemsScreenProduct.quantityPerLot} ${widget.listedItemsScreenProduct.quantityUnit}",
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Text(
                "Open Orders : ",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                "${widget.listedItemsScreenProduct.openOrders}",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SellerEditItemScreen(
                        productId: widget.listedItemsScreenProduct.productId,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_note_rounded,
                ),
                label: const Text(
                  "Edit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  deleteItem();
                },
                icon: const Icon(
                  Icons.delete_rounded,
                  color: Color.fromARGB(255, 252, 96, 85),
                ),
                label: const Text(
                  "Delete",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 252, 96, 85),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Switch(
                  thumbIcon: thumbIcon,
                  value: switchSelection,
                  onChanged: (switchval) async {
                    await http.post(
                      productUpdateUrl,
                      headers: {
                        'Authorization': loggedInUserAuthToken,
                        'Content-Type': 'application/json'
                      },
                      body: json.encode(
                        {
                          "productId":
                              widget.listedItemsScreenProduct.productId,
                          "availStatus": switchval,
                        },
                      ),
                    );
                    setState(() {
                      switchSelection = switchval;
                    });
                  })
            ],
          ),
        ],
      ),
    );
  }
}

final MaterialStateProperty<Icon?> thumbIcon =
    MaterialStateProperty.resolveWith<Icon?>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  },
);
