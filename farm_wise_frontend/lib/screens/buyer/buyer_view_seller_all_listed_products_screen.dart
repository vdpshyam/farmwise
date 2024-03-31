import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import 'buyer_item_detail_screen.dart';

class BVSellerListedProductsScreen extends StatefulWidget {
  const BVSellerListedProductsScreen(
      {super.key, required this.userId, required this.userName});

  final String userId, userName;

  @override
  State<BVSellerListedProductsScreen> createState() =>
      _BVSellerListedProductsScreenState();
}

class SellerListedProductsListTile {
  String productId, productName, quantityUnit;
  int basePrice;
  List productImages;

  SellerListedProductsListTile({
    required this.productId,
    required this.productName,
    required this.quantityUnit,
    required this.basePrice,
    required this.productImages,
  });
}

class _BVSellerListedProductsScreenState
    extends State<BVSellerListedProductsScreen> {
  bool isLoading = true;
  late Uri getProductsListUrl;

  List<SellerListedProductsListTile> productsList = [];

  void getProductsList() {
    http.get(
      getProductsListUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      var getProductsListResp = json.decode(response.body);
      if (response.statusCode == 200) {
        if (getProductsListResp["message"] == 'Products by limit found') {
          for (int i = 0;
              i < getProductsListResp["productsByLimit"].length;
              i++) {
            // debugPrint(getProductsListResp["productsListMinDetails"]);
            productsList.add(
              SellerListedProductsListTile(
                productId: getProductsListResp['productsByLimit'][i]["_id"],
                productName: getProductsListResp['productsByLimit'][i]
                    ["productName"],
                quantityUnit: getProductsListResp['productsByLimit'][i]
                    ["quantityUnit"],
                basePrice: getProductsListResp['productsByLimit'][i]
                    ["basePrice"],
                productImages: getProductsListResp['productsByLimit'][i]
                    ["productImages"],
              ),
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        final snackBar = SnackBar(
          content: const Text(
            'Something went wrong.Could not fetch reviews. Try again later.',
          ),
          action: SnackBarAction(
            label: 'okay',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getProductsListUrl = Uri.http(
      authority,
      "api/farmer/getProductsLimit",
      {
        "userId": widget.userId,
        "noOfProd": "0",
      },
    );
    getProductsList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 37, 143, 83),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "${widget.userName}'s listed products",
              ),
            ),
            body: ListView.builder(
              
              shrinkWrap: true,
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return BuyerItemDetailScreen(
                                productId: productsList[index].productId,
                              );
                            },
                          ),
                        );
                      },
                      leading: SizedBox(
                        width: 85,
                        child: Image.network(
                          productsList[index].productImages[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(productsList[index].productName),
                      subtitle: Text(
                        "Rs.${productsList[index].basePrice}/${productsList[index].quantityUnit}",
                      ),
                    ),
                    const Divider(
                      height: 0,
                      indent: 60,
                      endIndent: 60,
                    ),
                  ],
                );
              },
            ),
          );
  }
}
