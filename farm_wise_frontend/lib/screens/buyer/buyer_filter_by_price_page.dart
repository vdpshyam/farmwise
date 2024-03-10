import 'package:flutter/material.dart';

import '../../providers/filters_provider.dart';

class BuyerFilterByPricePage extends StatefulWidget {
  const BuyerFilterByPricePage(
      {super.key, required this.searchTerm, required this.priceRange});

  final String searchTerm;
  final List<int> priceRange;

  @override
  State<BuyerFilterByPricePage> createState() => _BuyerFilterByPricePageState();
}

class _BuyerFilterByPricePageState extends State<BuyerFilterByPricePage> {
  // bool isLoading = true;
  late int minPrice, maxPrice;
  late RangeValues _currentRangeValues;

  // List<int> checkedProductsPricesList = [];

  // void getProductsPricesList() {
  //   http.get(
  //     getProductPricesUrl,
  //     headers: {'Content-Type': 'application/json'},
  //   ).then((response) {
  //     if (response.statusCode == 200) {
  //       var getProductPricesResp = json.decode(response.body);
  //       print(getProductPricesResp);
  //       if (getProductPricesResp['message'] == "Products prices received") {
  //         for (int i = 0;
  //             i < getProductPricesResp['pricesList'][0]['prices'].length;
  //             i++) {
  //           checkedProductsPricesList
  //               .add(getProductPricesResp['pricesList'][0]['prices'][i]);
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
    minPrice = widget.priceRange.first;
    maxPrice = widget.priceRange.last;
    _currentRangeValues = RangeValues(minPrice.toDouble(), maxPrice.toDouble());
    debugPrint("minprice : $minPrice");
    debugPrint("maxPrice : $maxPrice");
    debugPrint("_currentRangeValues : $_currentRangeValues");
    // getProductPricesUrl = Uri.http(
    //   authority,
    //   'api/common/getProductPriceList',
    //   {"searchTerm": widget.searchTerm},
    // );
    // getProductsPricesList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Select price range",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 40.0, right: 40, top: 15, bottom: 15),
          child: Text(
            "*The results will be shown based on the base price of the product.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Min : Rs.${widget.priceRange.first}"),
              Text("Max : Rs.${widget.priceRange.last}"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: RangeSlider(
            values: _currentRangeValues,
            min: minPrice.toDouble(),
            max: maxPrice.toDouble(),
            divisions: minPrice == maxPrice ? null : maxPrice - minPrice,
            labels: RangeLabels(
              _currentRangeValues.start.round().toString(),
              _currentRangeValues.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
              pricesRangeList[0] = values.start.toInt();
              pricesRangeList[1] = values.end.toInt();
              debugPrint("pricesRangeList : $pricesRangeList");
            },
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(
                "Selected range : ",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    "Min",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    _currentRangeValues.start.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Column(
                children: [
                  const Text(
                    "Max",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _currentRangeValues.end.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
