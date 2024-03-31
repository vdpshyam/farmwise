import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:farm_wise_frontend/providers/https_provider.dart';
import 'package:farm_wise_frontend/providers/user_details_provider.dart';
import '../../custom_widgets/buyer_favorite_tile_widget.dart';
import '../../models/favorite_product_tile.dart';
import '../../providers/favorite_product_tile.dart';
import 'buyer_item_detail_screen.dart';

class BuyerFavoritesPage extends StatefulWidget {
  const BuyerFavoritesPage({super.key});

  @override
  State<BuyerFavoritesPage> createState() => _BuyerFavoritesPageState();
}

class _BuyerFavoritesPageState extends State<BuyerFavoritesPage> {
  late Uri favoriteProductsDetailsUrl;
  bool isLoading = true;

  void getFavoriteProductDetails() {
    favoriteProductsTiles.clear();
    favoriteProductsDetailsUrl =
        Uri.http(authority, 'api/common/getFavoriteProducts', {
      "buyerId": loggedInUserDetails.userId,
    });

    http.get(
      favoriteProductsDetailsUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var favoriteProductsDetailsResp = json.decode(response.body);
        if (favoriteProductsDetailsResp['productDetails'].length > 0) {
          if (favoriteProductsDetailsResp["message"] ==
              "Fav products recieved") {
            for (int i = 0;
                i < favoriteProductsDetailsResp['productDetails'].length;
                i++) {
              // print(favoriteProductsDetailsResp['productDetails'][i][0]["_id"]);
              favoriteProductsTiles.add(
                FavoriteProductTile(
                  productId: favoriteProductsDetailsResp['productDetails'][i][0]
                      ['_id'],
                  productName: favoriteProductsDetailsResp['productDetails'][i]
                      [0]['productName'],
                  basePrice: favoriteProductsDetailsResp['productDetails'][i][0]
                      ['basePrice'],
                  quantityUnit: favoriteProductsDetailsResp['productDetails'][i]
                      [0]['quantityUnit'],
                  location: favoriteProductsDetailsResp['productDetails'][i][0]
                      ['sellerDetails'][0]['city'],
                  sellerName: favoriteProductsDetailsResp['productDetails'][i]
                      [0]['sellerDetails'][0]['userName'],
                  productImageUrl: favoriteProductsDetailsResp['productDetails']
                      [i][0]['productImages'][0],
                ),
              );
            }
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    });

    // favoriteProductsTiles.clear();
    // if (loggedInUserDetails.favoriteProducts.isNotEmpty) {
    //   for (int i = 0; i < loggedInUserDetails.favoriteProducts.length; i++) {
    //     favoriteProductsDetailsUrl =
    //         Uri.http(authority, 'api/common/getProductDetails', {
    //       "id": loggedInUserDetails.favoriteProducts[i],
    //     });
    //     http.get(
    //       favoriteProductsDetailsUrl,
    //       headers: {'Content-Type': 'application/json'},
    //     ).then((response) {

    //     });
    //   }
    // } else {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    getFavoriteProductDetails();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getFavoriteProductDetails();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(
            height: 610,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : RefreshIndicator(
            onRefresh: _onRefresh,
            child: favoriteProductsTiles.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 180,
                        ),
                        SizedBox(
                          height: 180,
                          child: Image.asset(
                            "lib/assets/images/favorite11.png",
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 10),
                          child: Text(
                            "No favorite products added yet. Your favorite products appear here. You can favorite a product that you regularly or you are likely buy in the near future.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favoriteProductsTiles.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BuyerItemDetailScreen(
                                    productId:
                                        favoriteProductsTiles[index].productId,
                                  ),
                                ),
                              );
                            },
                            child: BuyerFavoriteTileWidget(
                              product: favoriteProductsTiles[index],
                            ),
                          ),
                          const Divider(
                            height: 0,
                            indent: 30,
                            endIndent: 30,
                          ),
                        ],
                      );
                    },
                  ),
          );
  }
}
