import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/providers/https_provider.dart';

import '../../custom_widgets/buyer_filter_widget.dart';
import '../../custom_widgets/buyer_product_mini_detail_tile_widget.dart';
import '../../models/product_search_result_tile.dart';
import '../../providers/filters_provider.dart';
import '../../providers/product_search_result_tile_provider.dart';
import '../../providers/user_details_provider.dart';
import 'buyer_item_detail_screen.dart';

class BuyerSearchPage extends StatefulWidget {
  const BuyerSearchPage({super.key});

  @override
  State<BuyerSearchPage> createState() => _BuyerSearchPageState();
}

//Sort variables
enum SortType {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  closestProducedDate,
  farthestProducedDate,
  closestAvailableDate,
  farthestAvailableDate
}

class _BuyerSearchPageState extends State<BuyerSearchPage> {
  late TextEditingController _searchBarController;
  late Uri productSearchUrl, productNamesUrl;
  SortType? _sortType = SortType.relevance;
  // int _filterSelectedIndex = 0;
  bool isLoading = false, isFiltersResultsEmpty = false;
  List<String> searchSuggestionsAll = [], searchSuggestionMatched = [];

  void getSearchSuggestions() {
    http.get(
      productNamesUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var getSearchSuggestionsResp = json.decode(response.body);
        if (getSearchSuggestionsResp["message"] == "Products name recieved") {
          for (int i = 0;
              i < getSearchSuggestionsResp["products"].length;
              i++) {
            searchSuggestionsAll
                .add(getSearchSuggestionsResp["products"][i]["value"]);
          }
        }
      }
    });
  }

  void getSearchResults(value) {
    productSearchUrl = Uri.http(
      authority,
      'api/common/getSearchResults',
      {
        "searchTerm": value,
        "productlimit": "20",
      },
    );
    http.get(
      productSearchUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      var getSearchResultsResp = json.decode(response.body);
      if (getSearchResultsResp["message"] == "Products list recieved") {
        var searchResultsProductsTemp = getSearchResultsResp["products"];
        searchResultsProducts.clear();
        for (int i = 0; i < searchResultsProductsTemp.length; i++) {
          searchResultsProducts.add(
            ProductSearchResultTile(
              productId: searchResultsProductsTemp[i]["_id"],
              basePrice: searchResultsProductsTemp[i]["basePrice"],
              productName: searchResultsProductsTemp[i]["productName"],
              quantityUnit: searchResultsProductsTemp[i]["quantityUnit"],
              location: searchResultsProductsTemp[i]["sellerDetails"][0]
                  ["city"],
              sellerName: searchResultsProductsTemp[i]["sellerDetails"][0]
                  ["userName"],
              productImageUrl: searchResultsProductsTemp[i]["productImages"][0],
            ),
          );
        }
      } else {
        setState(() {
          searchResultsProducts.clear();
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void showFilteredProducts(value) {
    debugPrint("filetrsLocationsList : $locationsList");
    debugPrint("filetrsPricesRangeList : $pricesRangeList");
    debugPrint("filetrsProducedDateRangeList : $producedDateRangeList");
    debugPrint("filetrsAvailableFromDateRangeList : $availableFromDateRangeList");
    var convertedproducedDateRangeList = producedDateRangeList.map(
      (e) {
        return e.toUtc().toString();
      },
    );
    var convertedavailableFromDateRangeList = availableFromDateRangeList.map(
      (e) {
        return e.toUtc().toString();
      },
    );
    if (locationsList.isEmpty) {
      setState(() {
        locationsList = selectedLocationsList;
      });
    }
    setState(() {
      isLoading = true;
    });

    var filetrProductSearchUrl = Uri.http(
      authority,
      'api/common/getSearchResultsByFilters',
      {
        "searchTerm": value,
      },
    );
    http
        .post(filetrProductSearchUrl,
            headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
            body: json.encode({
              "locationList": locationsList,
              "priceRange": pricesRangeList,
              "producedDateRange": convertedproducedDateRangeList.toList(),
              "availableFromDateRange":
                  convertedavailableFromDateRangeList.toList()
            }))
        .then((response) {
      searchResultsProducts.clear();
      var getSearchResultsResp = json.decode(response.body);
      if (response.statusCode == 200) {
        if (getSearchResultsResp["message"] == "Products list recieved") {
          var searchResultsProductsTemp = getSearchResultsResp["products"];
          for (int i = 0; i < searchResultsProductsTemp.length; i++) {
            searchResultsProducts.add(
              ProductSearchResultTile(
                productId: searchResultsProductsTemp[i]["_id"],
                basePrice: searchResultsProductsTemp[i]["basePrice"],
                productName: searchResultsProductsTemp[i]["productName"],
                quantityUnit: searchResultsProductsTemp[i]["quantityUnit"],
                location: searchResultsProductsTemp[i]["sellerDetails"][0]
                    ["city"],
                sellerName: searchResultsProductsTemp[i]["sellerDetails"][0]
                    ["userName"],
                productImageUrl: searchResultsProductsTemp[i]["productImages"]
                    [0],
              ),
            );
          }
        } else {
          setState(() {
            isFiltersResultsEmpty = true;
          });
        }
      }
      setState(() {
        isLoading = false;
      });
      resultsListViewBuilder();
    });
  }

  void showSortedProducts(value, sortAccordingTo, closestFarthest) {
    // var convertedproducedDateRangeList = producedDateRangeList.map(
    //   (e) {
    //     return e.toUtc().toString();
    //   },
    // );
    // var convertedavailableFromDateRangeList = availableFromDateRangeList.map(
    //   (e) {
    //     return e.toUtc().toString();
    //   },
    // );
    // setState(() {
    //   isLoading = true;
    // });

    var sortProductSearchUrl = Uri.http(
      authority,
      'api/common/getSearchResultsBySort',
      {
        "searchTerm": value,
        "sortAccordingTo": sortAccordingTo,
        "closestFarthest": closestFarthest
      },
    );
    http.get(
      sortProductSearchUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      var getSearchResultsResp = json.decode(response.body);
      if (getSearchResultsResp["message"] == "Products list recieved") {
        var searchResultsProductsTemp = getSearchResultsResp["products"];
        searchResultsProducts.clear();
        for (int i = 0; i < searchResultsProductsTemp.length; i++) {
          searchResultsProducts.add(
            ProductSearchResultTile(
              productId: searchResultsProductsTemp[i]["_id"],
              basePrice: searchResultsProductsTemp[i]["basePrice"],
              productName: searchResultsProductsTemp[i]["productName"],
              quantityUnit: searchResultsProductsTemp[i]["quantityUnit"],
              location: searchResultsProductsTemp[i]["sellerDetails"][0]
                  ["city"],
              sellerName: searchResultsProductsTemp[i]["sellerDetails"][0]
                  ["userName"],
              productImageUrl: searchResultsProductsTemp[i]["productImages"][0],
            ),
          );
        }
      }
      setState(() {
        isLoading = false;
      });
      resultsListViewBuilder();
    });
  }

  @override
  void initState() {
    super.initState();
    productSearchUrl = Uri.http(
      authority,
      'api/common/getSearchResults',
      {
        "searchTerm": "",
        "productlimit": "10",
      },
    );
    productNamesUrl = Uri.http(
      authority,
      'api/common/getProductsName',
    );
    _searchBarController = TextEditingController();
    getSearchSuggestions();
    locationsList = [];
    pricesRangeList = [];
    producedDateRangeList = [0, 0];
    availableFromDateRangeList = [0, 0];
    searchResultsProducts.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 8,
            ),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') {
                  return searchSuggestionsAll;
                }
                return searchSuggestionsAll.where((String item) {
                  return item
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              optionsViewBuilder:
                  (context, Function(String) onSelected, options) {
                return Material(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option.toString(),
                        ),
                        onTap: () {
                          onSelected(option.toString());
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 0,
                        indent: 20,
                        endIndent: 60,
                      );
                    },
                    itemCount: options.length,
                  ),
                );
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                _searchBarController = textEditingController;
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onFieldSubmitted,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 13, 95, 69),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                    ),
                    labelText: 'What are you looking for?',
                    contentPadding: EdgeInsets.all(15),
                  ),
                );
              },
              onSelected: (String item) {
                debugPrint("Item : $item");
                setState(() {
                  isLoading = true;
                });
                FocusManager.instance.primaryFocus?.unfocus();
                getSearchResults(item);
              },
              // onTap: () {
              //   getSearchSuggestions();
              // },
              // onFieldSubmitted: (value) {
              //   setState(() {
              //     isLoading = true;
              //   });
              //   getSearchResults(value);
              // },
              // controller: _searchBarController,
              // decoration: const InputDecoration(
              //   suffixIcon: Icon(
              //     Icons.search,
              //     color: Color.fromARGB(255, 13, 95, 69),
              //   ),
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(50.0),
              //     ),
              //   ),
              //   labelText: 'What are you looking for?',
              //   contentPadding: EdgeInsets.all(15),
              // ),
            ),
            if (searchResultsProducts.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 25.0,
                                ),
                                child: Text(
                                  "Sort by",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Divider(
                                indent: 60,
                                endIndent: 60,
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Relevence",
                                ),
                                value: SortType.relevance,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  getSearchResults(_searchBarController.text);
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Price - Low to high",
                                ),
                                value: SortType.priceLowToHigh,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "basePrice",
                                    "1",
                                  );
                                  // debugPrint(value.toString());
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Price - High to low",
                                ),
                                value: SortType.priceHighToLow,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "basePrice",
                                    "-1",
                                  );
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Produced date - Closest first",
                                ),
                                value: SortType.closestProducedDate,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "producedDate",
                                    "-1",
                                  );
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Produced date - Farthest first",
                                ),
                                value: SortType.farthestProducedDate,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "producedDate",
                                    "1",
                                  );
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Available from date - Closest first",
                                ),
                                value: SortType.closestAvailableDate,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "availableFrom",
                                    "-1",
                                  );
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              RadioListTile<SortType>(
                                title: const Text(
                                  "Available from date - Farthest first",
                                ),
                                value: SortType.farthestAvailableDate,
                                groupValue: _sortType,
                                onChanged: (value) {
                                  showSortedProducts(
                                    _searchBarController.text,
                                    "availableFrom",
                                    "1",
                                  );
                                  setState(() {
                                    _sortType = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.sort),
                    label: const Text("Sort"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return BuyerFilterWidget(
                            searchTerm: _searchBarController.text,
                            filterFunc: showFilteredProducts,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Filter"),
                  )
                ],
              ),
            isLoading
                ? const SizedBox(
                    height: 610,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SizedBox(
                    height: 610,
                    child: searchResultsProducts.isEmpty &&
                            !isFiltersResultsEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 150,
                                ),
                                SizedBox(
                                  height: 250,
                                  child: Image.asset(
                                      'lib/assets/images/search2.png'),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text("Search for something..."),
                              ],
                            ),
                          )
                        : searchResultsProducts.isEmpty && isFiltersResultsEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    SizedBox(
                                      height: 300,
                                      child: Image.asset(
                                          "lib/assets/images/nofilterproducts1.png"),
                                    ),
                                    const Text(
                                        "No products found for the chosen filters..."),
                                  ],
                                ),
                              )
                            : resultsListViewBuilder(),
                  )
          ],
        ),
      ),
    );
  }
}

Widget resultsListViewBuilder() {
  return ListView.builder(
    itemCount: searchResultsProducts.length,
    itemBuilder: (context, index) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BuyerItemDetailScreen(
                    productId: searchResultsProducts[index].productId,
                  ),
                ),
              );
            },
            child: BuyerProductMiniDetailTileWidget(
              product: searchResultsProducts[index],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    },
  );
}
