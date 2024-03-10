import 'package:flutter/material.dart';

import '../../providers/filters_provider.dart';

class BuyerFilterByLocationPage extends StatefulWidget {
  const BuyerFilterByLocationPage(
      {super.key, required this.searchTerm, required this.productsLocationsList});
  final String searchTerm;
  final List<String> productsLocationsList;

  @override
  State<BuyerFilterByLocationPage> createState() =>
      _BuyerFilterByLocationPageState();
}

class _BuyerFilterByLocationPageState extends State<BuyerFilterByLocationPage> {
  // late List<String> _selectedLocationList;
  // bool isLoading = true;
  // late Uri getProductLocationsUrl;

  // List<String> productsLocationsList = [], checkedProductsLocationsList = [];

  // void getproductsLocationsList() {
  //   http.get(
  //     getProductLocationsUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ).then((response) {
  //     if (response.statusCode == 200) {
  //       var getProductLocationsResp = json.decode(response.body);
  //       // print(getProductLocationsResp);
  //       if (getProductLocationsResp['message'] ==
  //           "Products locations received") {
  //         for (int i = 0;
  //             i < getProductLocationsResp['locationsList'].length;
  //             i++) {
  //           productsLocationsList
  //               .add(getProductLocationsResp['locationsList'][i]['_id']);
  //         }
  //       }
  //     }
  //   }).then((value) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // _selectedLocationList = widget.productsLocationsList;
    // getProductLocationsUrl = Uri.https(
    //   authority,
    //   'api/common/getProductLocationList',
    //   {"searchTerm": widget.searchTerm},
    // );
    // getproductsLocationsList();
  }

  @override
  Widget build(BuildContext context) {
    return 
    // isLoading
    //     ? const Center(
    //         child: CircularProgressIndicator(
    //           color: Color.fromARGB(255, 37, 143, 83),
    //         ),
    //       )
    //     : 
        ListView.builder(
            shrinkWrap: true,
            itemCount: widget.productsLocationsList.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                  widget.productsLocationsList[index],
                ),
                value: locationsList
                    .contains(widget.productsLocationsList[index]),
                onChanged: (value) {
                  setState(() {
                    if (locationsList
                        .contains(widget.productsLocationsList[index])) {
                      locationsList
                          .remove(widget.productsLocationsList[index]);
                    } else {
                      locationsList
                          .add(widget.productsLocationsList[index]);
                    }
                  });
                },
              );
            },
          );
  }
}
