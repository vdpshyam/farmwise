import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../../models/product.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import 'seller_edit_item_screen.dart';

// class Product {
//   String productId, productName, quantityUnit, productDesc;
//   DateTime producedDate, availableFrom;
//   num basePrice, quantityPerLot, minNoLot, ratings;
//   bool availStatus;
//   List? productImages = [], reviews = [], ratedUser = [];

//   Product({
//     required this.productId,
//     required this.productName,
//     required this.quantityUnit,
//     required this.productDesc,
//     required this.producedDate,
//     required this.availableFrom,
//     required this.basePrice,
//     required this.quantityPerLot,
//     required this.minNoLot,
//     required this.ratings,
//     required this.availStatus,
//     required this.productImages,
//     required this.reviews,
//     required this.ratedUser,
//   });
// }

class SellerViewListedItemScreen extends StatefulWidget {
  const SellerViewListedItemScreen(
      {super.key, required this.productId, required this.refresh});
  final String productId;
  final Function refresh;

  @override
  State<SellerViewListedItemScreen> createState() =>
      _SellerViewListedItemScreenState();
}

class _SellerViewListedItemScreenState
    extends State<SellerViewListedItemScreen> {
  late Uri getProductDetailsUrl, productBidDetailUrl, productUpdateUrl;
  late bool switchSelection;
  bool isLoading = true;

  late String productId, productName, quantityUnit, productDesc;
  late DateTime producedDate, availableFrom;
  late num basePrice, quantityPerLot, minNoLot, ratings;
  late bool availStatus;
  late List productImages = [], reviews = [], ratedUser = [];

  int openPendingOrders = 0, maxBid = 0, minBid = 0, avgBid = 0;

  void getProductDetails() {
    http.get(
      getProductDetailsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductDetailsResp = json.decode(response.body);
        if (getProductDetailsResp["message"] == "Product details found") {
          if (getProductDetailsResp["productDetails"].length > 0) {
            productId = getProductDetailsResp["productDetails"][0]["_id"];
            productName =
                getProductDetailsResp["productDetails"][0]["productName"];
            quantityUnit =
                getProductDetailsResp["productDetails"][0]["quantityUnit"];
            productDesc =
                getProductDetailsResp["productDetails"][0]["productDesc"];
            producedDate = DateTime.parse(
                getProductDetailsResp["productDetails"][0]["producedDate"]);
            availableFrom = DateTime.parse(
                getProductDetailsResp["productDetails"][0]["availableFrom"]);
            basePrice = getProductDetailsResp["productDetails"][0]["basePrice"];
            quantityPerLot =
                getProductDetailsResp["productDetails"][0]["quantityPerLot"];
            minNoLot = getProductDetailsResp["productDetails"][0]["minNoLot"];
            ratings = getProductDetailsResp["productDetails"][0]["ratings"];
            availStatus =
                getProductDetailsResp["productDetails"][0]["availStatus"];
            productImages =
                getProductDetailsResp["productDetails"][0]["productImages"];
            reviews = getProductDetailsResp["productDetails"][0]["reviews"];
            ratedUser = getProductDetailsResp["productDetails"][0]["ratedUser"];
            setState(() {
              switchSelection = availStatus;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No item found!'),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not load item details.Try again later.'),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          ),
        );
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getProductBidDetails() {
    http.get(
      productBidDetailUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductBidDetailsResp = json.decode(response.body);
        if (getProductBidDetailsResp["message"] == "Product bids received") {
          if (getProductBidDetailsResp["productBids"].length > 0) {
            setState(() {
              isLoading = false;
              openPendingOrders =
                  getProductBidDetailsResp["productBids"][0]["count"];
              maxBid = getProductBidDetailsResp["productBids"][0]["max"].ceil();
              minBid = getProductBidDetailsResp["productBids"][0]["min"].ceil();
              avgBid = getProductBidDetailsResp["productBids"][0]["avg"].ceil();
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  void deleteItem() {
    if (openPendingOrders > 0) {
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
                    headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                    body: json.encode(
                      {
                        "productId": widget.productId,
                        "availStatus": false,
                      },
                    ),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      var deactProdResp = json.decode(response.body);
                      if (deactProdResp["msg"] ==
                          "Product Updated Successfully") {
                        widget.refresh();
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
                  var productDeleteUrl = Uri.http(
                    authority,
                    'api/farmer/deleteproduct',
                  );
                  Navigator.of(context).pop();
                  http
                      .post(
                    productDeleteUrl,
                    headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                    body: json.encode(
                      {
                        "productId": widget.productId,
                      },
                    ),
                  )
                      .then((response) {
                    if (response.statusCode == 200) {
                      var deleteUrlResp = json.decode(response.body);
                      if (deleteUrlResp["msg"] ==
                          "Product Removed successfully") {
                        widget.refresh();
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

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getProductDetails();
    getProductBidDetails();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    getProductDetailsUrl = Uri.http(
      authority,
      "api/farmer/getProductDetails",
      {
        "productId": widget.productId,
      },
    );
    productBidDetailUrl = Uri.http(authority, "api/common/getProductBids",
        {"productId": widget.productId});
    productUpdateUrl = Uri.http(
      authority,
      'api/farmer/updateproduct',
    );
    getProductDetails();
    getProductBidDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            "product#${widget.productId}",
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Available Status : ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                            thumbIcon: thumbIcon,
                            value: switchSelection,
                            onChanged: (switchval) async {
                              await http.post(
                                productUpdateUrl,
                                headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                                body: json.encode(
                                  {
                                    "productId": widget.productId,
                                    "availStatus": switchval,
                                  },
                                ),
                              );
                              widget.refresh();
                              setState(() {
                                switchSelection = switchval;
                              });
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          // borderRadius: BorderRadius.circular(15),
                          // border: Border(
                          // top: BorderSide(width: 0.2, color: Color.fromARGB(255, 137, 137, 137)),
                          // left: BorderSide(color: Colors.black),
                          // right: BorderSide(color: Colors.black),
                          // bottom:
                          // BorderSide(width: 0.7, color: Color.fromARGB(255, 137, 137, 137)),
                          // ),
                          ),
                      width: double.maxFinite,
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Image.network(
                          productImages[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                productName,
                                style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Base price : $basePrice/$quantityUnit",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Bids summary : ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Current placed orders : $openPendingOrders",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (openPendingOrders == 0)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: Text(
                                  "No bidding details yet.When there are placed orders, the bidding summary of the product appears here.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (openPendingOrders > 0)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            const Text(
                                              "Max bid",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "$maxBid",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Text(
                                              "Avg bid",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "$avgBid",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Text(
                                              "Min bid",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "$minBid",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10.0,
                                        right: 10,
                                      ),
                                      child: Text(
                                        "*Bid summary in (amount in Rs.)/$quantityUnit",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Product details :",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Quantity per lot (in $quantityUnit) : $quantityPerLot",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Min no. of lot(s) : $minNoLot",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Produced date : ${producedDate.toLocal().day}/${producedDate.toLocal().month}/${producedDate.toLocal().year}",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Available for orders from : ${availableFrom.toLocal().day}/${availableFrom.toLocal().month}/${availableFrom.toLocal().year}",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 8.0, left: 8, right: 8),
                              child: Text(
                                "Product description: ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                productDesc,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            const Divider(
                              indent: 30,
                              endIndent: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SellerEditItemScreen(
                                    productId: widget.productId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit_note_rounded,
                            ),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.normal),
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
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 252, 96, 85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
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
