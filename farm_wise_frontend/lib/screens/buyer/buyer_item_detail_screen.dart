import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../user_public_profile_screen.dart';
// import 'buyer_payment_settings_screen.dart';
import 'buyer_place_order_screen.dart';

class BuyerItemDetailScreen extends StatefulWidget {
  const BuyerItemDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<BuyerItemDetailScreen> createState() => _BuyerItemDetailScreenState();
}

class _BuyerItemDetailScreenState extends State<BuyerItemDetailScreen> {
  late Uri productDetailUrl, toggleFavoritesUrl, productBidDetailUrl;
  bool isLoading = true;
  bool isFavorite = false;

  late String productName,
      sellerId,
      location,
      sellerName,
      sellerMobile,
      quantityUnit,
      productDesc;
  late int basePrice, quantityPerLot, minNoLot;
  late DateTime producedDate, availableFrom;
  late List<dynamic> productImages;

  int openPendingOrders = 0, maxBid = 0, minBid = 0, avgBid = 0;

  void checkIsFavorite() {
    setState(() {
      isFavorite =
          loggedInUserDetails.favoriteProducts.contains(widget.productId);
    });
  }

  void toggleFavorites() {
    toggleFavoritesUrl = Uri.https(
      authority,
      "api/common/toggleFavorites",
    );
    http
        .put(toggleFavoritesUrl,
            headers: {
              'Authorization': loggedInUserAuthToken,
              'Content-Type': 'application/json'
            },
            body: json.encode({
              "userId": loggedInUserDetails.userId,
              "productId": widget.productId
            }))
        .then((response) {
      var toggleFavoritesResp = json.decode(response.body);
      if (toggleFavoritesResp["message"] == "User favorites updated") {
        if (loggedInUserDetails.favoriteProducts.contains(widget.productId)) {
          loggedInUserDetails.favoriteProducts.remove(widget.productId);
        } else {
          loggedInUserDetails.favoriteProducts.add(widget.productId);
        }
      }
      setState(() {
        isFavorite =
            loggedInUserDetails.favoriteProducts.contains(widget.productId);
      });
    });
  }

  void getProductDetails() {
    http.get(
      productDetailUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      var getProductDetailsResp = json.decode(response.body);
      if (getProductDetailsResp["message"] == "Product details found") {
        var productDetails = getProductDetailsResp["productDetails"];
        if (productDetails.length > 0) {
          productName = productDetails[0]["productName"];
          quantityUnit = productDetails[0]["quantityUnit"];
          basePrice = productDetails[0]["basePrice"];
          quantityPerLot = productDetails[0]["quantityPerLot"];
          minNoLot = productDetails[0]["minNoLot"];
          producedDate = DateTime.parse(productDetails[0]["producedDate"]);
          availableFrom = DateTime.parse(productDetails[0]["availableFrom"]);
          productImages = productDetails[0]["productImages"];
          productDesc = productDetails[0]["productDesc"];
        }

        if (productDetails[0]["sellerDetails"].length > 0) {
          location = productDetails[0]["sellerDetails"][0]["city"];
          sellerId = productDetails[0]["sellerDetails"][0]["_id"];
          sellerName = productDetails[0]["sellerDetails"][0]["userName"];
          sellerMobile = productDetails[0]["sellerDetails"][0]["mobile"];
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void getProductBidDetails() {
    http.get(
      productBidDetailUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductBidDetailsResp = json.decode(response.body);
        if (getProductBidDetailsResp["message"] == "Product bids received") {
          if (getProductBidDetailsResp["productBids"].length > 0) {
            openPendingOrders =
                getProductBidDetailsResp["productBids"][0]["count"];
            maxBid = getProductBidDetailsResp["productBids"][0]["max"];
            minBid = getProductBidDetailsResp["productBids"][0]["min"];
            avgBid = getProductBidDetailsResp["productBids"][0]["avg"];
          }
        }
      }
    });
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
    isLoading = true;
    productDetailUrl = Uri.https(
        authority, "api/common/getProductDetails", {"id": widget.productId});
    productBidDetailUrl = Uri.https(authority, "api/common/getProductBids",
        {"productId": widget.productId});
    isFavorite =
        loggedInUserDetails.favoriteProducts.contains(widget.productId);
    getProductDetails();
    getProductBidDetails();
    checkIsFavorite();
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
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 37, 143, 83),
              ),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
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
                          height: 263,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Image.network(
                              productImages[0]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            toggleFavorites();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              right: 20,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(224, 255, 255, 255),
                                borderRadius: BorderRadius.circular(50),
                                // border: const Border(
                                //   top: BorderSide(
                                //     width: 0.2,
                                //     color: Colors.black,
                                //   ),
                                //   left: BorderSide(
                                //     width: 0.2,
                                //     color: Colors.black,
                                //   ),
                                //   right: BorderSide(
                                //     width: 0.2,
                                //     color: Colors.black,
                                //   ),
                                //   bottom: BorderSide(
                                //     width: 0.2,
                                //     color: Colors.black,
                                //   ),
                                // ),
                              ),
                              child: isFavorite
                                  ? const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 26,
                                        color: Colors.red,
                                      ),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.favorite_outline,
                                        size: 26,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
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
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Location : $location",
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
                              indent: 50,
                              endIndent: 50,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Seller details : ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "Name : ",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return UserPublicProfileScreen(
                                            userId: sellerId,
                                          );
                                        },
                                      ));
                                    },
                                    child: Text(
                                      sellerName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color:
                                            Color.fromARGB(255, 27, 152, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "Mobile: $sellerMobile",
                            //     style: const TextStyle(fontSize: 15),
                            //   ),
                            // ),
                            const Divider(
                              indent: 50,
                              endIndent: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: FilledButton.icon(
                          onPressed: () {

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return BuyerPlaceOrderScreen(
                                    basePrice: basePrice,
                                    minNoLot: minNoLot,
                                    productImageUrl: productImages[0],
                                    productName: productName,
                                    quantityPerLot: quantityPerLot,
                                    quantityUnit: quantityUnit,
                                    sellerMobile: sellerMobile,
                                    sellerName: sellerName,
                                    productId: widget.productId,
                                  );
                                },
                              ),
                            );

                            // bool isPLaceOrderEligible;
                            // var checkIsPLaceOrderEligibleUrl = Uri.https(
                            //     authority,
                            //     'api/payment/checkIsPLaceOrderEligible', {
                            //   "userId": loggedInUserDetails.userId,
                            // });
                            // http.get(
                            //   checkIsPLaceOrderEligibleUrl,
                            //   headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
                            // ).then((response) {
                            //   if (response.statusCode == 200) {
                            //     var checkIsPLaceOrderEligibleResp =
                            //         json.decode(response.body);

                            //     isPLaceOrderEligible =
                            //         checkIsPLaceOrderEligibleResp[
                            //             'isPLaceOrderEligible'];
                            //     debugPrint(
                            //         "isPLaceOrderEligible : $isPLaceOrderEligible");
                            // if (isPLaceOrderEligible) {

                            // } else {
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return AlertDialog(
                            //         title: const Text(
                            //           "No enough credits to place order.",
                            //         ),
                            //         content: const Text(
                            //           "Please subscribe to get credits inorder to be able to place order.",
                            //           style: TextStyle(
                            //             fontSize: 17,
                            //           ),
                            //         ),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.of(context).pop();
                            //             },
                            //             child: const Text("okay"),
                            //           ),
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.of(context)
                            //                   .push(MaterialPageRoute(
                            //                 builder: (context) {
                            //                   return const BuyerPaymentSettingsScreen();
                            //                 },
                            //               ));
                            //             },
                            //             child: const Text("Subscribe now"),
                            //           ),
                            //         ],
                            //       );
                            //     },
                            //   );
                            // }
                            //   }
                            // });
                          },
                          label: const Text("Place Order"),
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
