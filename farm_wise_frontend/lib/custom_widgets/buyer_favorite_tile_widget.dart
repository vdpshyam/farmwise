import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/favorite_product_tile.dart';
import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';

class BuyerFavoriteTileWidget extends StatefulWidget {
  const BuyerFavoriteTileWidget({
    super.key,
    required this.product,
  });

  final FavoriteProductTile product;

  @override
  State<BuyerFavoriteTileWidget> createState() =>
      _BuyerFavoriteTileWidgetState();
}

class _BuyerFavoriteTileWidgetState extends State<BuyerFavoriteTileWidget> {
  bool isFavorite = true;
  late Uri toggleFavoritesUrl;

  void toggleFavorites() {
    try {
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
            loggedInUserDetails.favoriteProducts
                .remove(widget.product.productId);
          } else {
            loggedInUserDetails.favoriteProducts.add(widget.product.productId);
          }
        }
        setState(() {
          isFavorite = loggedInUserDetails.favoriteProducts
              .contains(widget.product.productId);
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong.Try again later!'),
          action: SnackBarAction(
            label: 'okay',
            onPressed: () {
              // Code to execute.
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(0, 121, 120, 120),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 130,
              width: 150,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Center(
                    child: Container(
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 7,
                      //   vertical: 7,
                      // ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(54, 160, 159, 159),
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
                          widget.product.productImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        toggleFavorites();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 3.0,
                        right: 3,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromARGB(187, 255, 255, 255),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 1,
                            top: 1.5,
                            left: 1,
                            right: 1,
                          ),
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: isFavorite
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.favorite_outline,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Price : ${widget.product.basePrice}/${widget.product.quantityUnit}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Location : ${widget.product.location}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Seller : ${widget.product.sellerName}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
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
