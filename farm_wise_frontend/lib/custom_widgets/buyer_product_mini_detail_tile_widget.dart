import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:farm_wise_frontend/providers/user_details_provider.dart';
import '../models/product_search_result_tile.dart';
import '../providers/https_provider.dart';

class BuyerProductMiniDetailTileWidget extends StatefulWidget {
  const BuyerProductMiniDetailTileWidget({super.key, required this.product});

  final ProductSearchResultTile product;

  @override
  State<BuyerProductMiniDetailTileWidget> createState() =>
      _BuyerProductMiniDetailTileWidgetState();
}

class _BuyerProductMiniDetailTileWidgetState
    extends State<BuyerProductMiniDetailTileWidget> {
  bool isFavorite = false;
  late Uri toggleFavoritesUrl;

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
              "productId": widget.product.productId
            }))
        .then((response) {
      var toggleFavoritesResp = json.decode(response.body);
      if (toggleFavoritesResp["message"] == "User favorites updated") {
        if (loggedInUserDetails.favoriteProducts
            .contains(widget.product.productId)) {
          loggedInUserDetails.favoriteProducts.remove(widget.product.productId);
        } else {
          loggedInUserDetails.favoriteProducts.add(widget.product.productId);
        }
      }
      setState(() {
        isFavorite = loggedInUserDetails.favoriteProducts
            .contains(widget.product.productId);
      });
    });
  }

  void checkIsFavorite() {
    setState(() {
      isFavorite = loggedInUserDetails.favoriteProducts
          .contains(widget.product.productId);
    });
  }

  @override
  void initState() {
    super.initState();
    checkIsFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(98, 0, 0, 0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.35,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Center(
                    child: Image.network(
                      widget.product.productImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     toggleFavorites();
                  //   },
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: const Color.fromARGB(81, 255, 255, 255),
                  //       borderRadius: BorderRadius.circular(5),
                  //       // border: const Border(
                  //       //   top: BorderSide(width: 0.1, color: Colors.black),
                  //       //   left: BorderSide(width: 0.1, color: Colors.black),
                  //       //   right: BorderSide(width: 0.1, color: Colors.black),
                  //       //   bottom: BorderSide(width: 0.1, color: Colors.black),
                  //       // ),
                  //     ),
                  //     child: isFavorite
                  //         ? const Padding(
                  //             padding: EdgeInsets.all(2.0),
                  //             child: Icon(
                  //               Icons.favorite,
                  //               color: Colors.red,
                  //             ),
                  //           )
                  //         : const Padding(
                  //             padding: EdgeInsets.all(2.0),
                  //             child: Icon(
                  //               Icons.favorite_outline,
                  //             ),
                  //           ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.25,
              width: MediaQuery.of(context).size.width * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                  ),
                  Text(
                    "Price : ${widget.product.basePrice}/${widget.product.quantityUnit}",
                  ),
                  Text(
                    "Location : ${widget.product.location}",
                  ),
                  Text(
                    "Seller : ${widget.product.sellerName}",
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
