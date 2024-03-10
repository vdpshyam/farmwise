import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/providers/https_provider.dart';
// import 'package:go_router/go_router.dart';

import '../../custom_widgets/seller_listscreen_item_widget.dart';
// import '../../models/product.dart';
import '../../providers/products_list_provider.dart';
import '../../providers/user_details_provider.dart';
import 'seller_add_item_screen.dart';
import 'seller_view_listed_item_screen.dart';

// int listitemsCount = 20;

class SellerListedItemsPage extends StatefulWidget {
  const SellerListedItemsPage({super.key});

  @override
  State<SellerListedItemsPage> createState() => _SellerListedItemsPageState();
}

class _SellerListedItemsPageState extends State<SellerListedItemsPage> {
  final Uri getAllProductsUrl = Uri.https(
    authority,
    'api/farmer/getListedItems',
    {
      "userId": loggedInUserDetails.userId,
    },
  );

  bool isLoading = true;

  void getListedProducts() {
    http.get(
      getAllProductsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) async {
      if (response.statusCode == 200) {
        var getAllProductsResp = json.decode(response.body);
        if (getAllProductsResp["message"] == "Listed products recieved") {
          productsList.clear();
          if (getAllProductsResp["listedProducts"].length > 0) {
            for (int i = 0;
                i < getAllProductsResp["listedProducts"].length;
                i++) {
              var openOrders = 0;
              //get open orders
              var getOenOrdersUrl = Uri.https(
                  authority, 'api/farmer/getOpenOrders', {
                "productId": getAllProductsResp["listedProducts"][i]["_id"]
              });
              await http.get(
                getOenOrdersUrl,
                headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
              ).then((response) {
                var getOpenOrdersResp = json.decode(response.body);
                if (response.statusCode == 200) {
                  if (getOpenOrdersResp['message'] == "orders count found") {
                    if (getOpenOrdersResp["ordersCount"].length > 0) {
                      openOrders =
                          getOpenOrdersResp["ordersCount"][0]["openOrders"];
                    }
                    // print("${widget.product.productName} : $openOrders : ${widget.product.productId}");
                  }
                  // debugPrint(getOpenOrdersResp);
                }
              });
              //get open orders end
              productsList.add(
                ListedItemsScreenProductModel(
                  productId: getAllProductsResp["listedProducts"][i]["_id"],
                  productName: getAllProductsResp["listedProducts"][i]
                      ["productName"],
                  quantityUnit: getAllProductsResp["listedProducts"][i]
                      ["quantityUnit"],
                  basePrice: getAllProductsResp["listedProducts"][i]
                      ["basePrice"],
                  quantityPerLot: getAllProductsResp["listedProducts"][i]
                      ["quantityPerLot"],
                  productImages: getAllProductsResp["listedProducts"][i]
                      ["productImages"],
                  availStatus: getAllProductsResp["listedProducts"][i]
                      ["availStatus"],
                  minNoLot: getAllProductsResp["listedProducts"][i]["minNoLot"],
                  openOrders: openOrders,
                ),
              );
            }
          }
        }
      }
    }).then((value) {
      for (int i = 0; i < productsList.length; i++) {
        productsList[i];
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void updateListedItemsList(productId) {
    setState(() {
      productsList.removeWhere((element) => element.productId == productId);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getListedProducts();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    getListedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 37, 143, 83),
                ),
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: productsList.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 170,
                            ),
                            SizedBox(
                              child: Image.asset(
                                  "lib/assets/images/listeditems1.png"),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 50.0,
                                vertical: 10,
                              ),
                              child: Text(
                                "No listed items yet. Your listed show up here. Add your first item from below.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: productsList.length,
                        itemBuilder: (context, index) {
                          return productsList.length - 1 != index
                              ? InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SellerViewListedItemScreen(
                                              productId:
                                                  productsList[index].productId,
                                              refresh: _onRefresh);
                                        },
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      SellerListscreenItemWidget(
                                          listedItemsScreenProduct:
                                              productsList[index],
                                          updateListedItemFunc:
                                              updateListedItemsList),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(
                                        height: 0,
                                        indent: 70,
                                        endIndent: 70,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return SellerViewListedItemScreen(
                                                  productId: productsList[index]
                                                      .productId,
                                                  refresh: _onRefresh);
                                            },
                                          ),
                                        );
                                      },
                                      child: SellerListscreenItemWidget(
                                          listedItemsScreenProduct:
                                              productsList[index],
                                          updateListedItemFunc:
                                              updateListedItemsList),
                                    ),
                                    const SizedBox(
                                      height: 70,
                                    ),
                                  ],
                                );
                        },
                      ),
              ),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.maxFinite,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SellerAddItemScreen(refreshFunc: _onRefresh,);
                        },
                      ),
                    );
                  },
                  label: const Text("Add New Item"),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )
      ],
    );
  }
}
