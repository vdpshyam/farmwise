import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../providers/filters_provider.dart';
import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/buyer/buyer_filter_by_available_date.dart';
import '../screens/buyer/buyer_filter_by_location_page.dart';
import '../screens/buyer/buyer_filter_by_price_page.dart';
import '../screens/buyer/buyer_filter_by_produced_date.dart';

class BuyerFilterWidget extends StatefulWidget {
  const BuyerFilterWidget(
      {super.key, required this.searchTerm, required this.filterFunc});

  final String searchTerm;
  final Function filterFunc;

  @override
  State<BuyerFilterWidget> createState() => _BuyerFilterWidgetState();
}

// List filetrWidgetLocationsList = [],
//     filetrWidgetPriceRangeList = [],
//     filetrWidgetProducedDateList = [],
//     filetrWidgetAvailableFromDateList = [];

class _BuyerFilterWidgetState extends State<BuyerFilterWidget> {
  int _filterSelectedIndex = 0;

  var logger = Logger(
    printer: PrettyPrinter(),
  );
  
  //location filters
  bool isLoading = true;
  late Uri getProductLocationsUrl;
  List<String> productsLocationsList = [];

  void getProductsLocationsList() {
    http.get(
      getProductLocationsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductLocationsResp = json.decode(response.body);
        // logger.d(getProductLocationsResp);
        if (getProductLocationsResp['message'] ==
            "Products locations received") {
          if (getProductLocationsResp['locationsList'].length > 0) {
            for (int i = 0;
                i < getProductLocationsResp['locationsList'].length;
                i++) {
              productsLocationsList
                  .add(getProductLocationsResp['locationsList'][i]['_id']);
            }
            setState(() {
              selectedLocationsList = productsLocationsList;
            });
          }
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  //price filters
  late Uri getProductPriceRangeUrl;
  List<int> productsPriceRangeList = [];

  void getProductsPriceRangeList() {
    http.get(
      getProductPriceRangeUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductPriceRangeResp = json.decode(response.body);
        // logger.d(getProductLocationsResp);
        if (getProductPriceRangeResp['message'] == "Products prices received") {
          // for (int i = 0;
          //     i < getProductPriceRangeResp['locationsList'].length;
          //     i++) {
          if (getProductPriceRangeResp['pricesList'].length > 0) {
            productsPriceRangeList
                .add(getProductPriceRangeResp['pricesList'][0]['min']);
            productsPriceRangeList
                .add(getProductPriceRangeResp['pricesList'][0]['max']);
            pricesRangeList.clear();
            pricesRangeList.add(productsPriceRangeList.first);
            pricesRangeList.add(productsPriceRangeList.last);
          }
          // pricesRangeList[1] = productsPriceRangeList.last;
          // }
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

//prodDate filters
  late Uri getProductProducedDatesUrl;
  List<DateTime> productsProducedDatesRangeList = [];

  void getProductsProducedDatesList() {
    http.get(
      getProductProducedDatesUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductProducedDatesResp = json.decode(response.body);
        logger.d(getProductProducedDatesResp);
        if (getProductProducedDatesResp['message'] ==
            "Products produced dates received") {
          if (getProductProducedDatesResp['producedDatesRange'].length > 0) {
            productsProducedDatesRangeList.add(
              DateTime.parse(
                getProductProducedDatesResp['producedDatesRange'][0]['min'],
              ).toLocal(),
            );
            productsProducedDatesRangeList.add(
              DateTime.parse(
                getProductProducedDatesResp['producedDatesRange'][0]['max'],
              ).toLocal(),
            );
            producedDateRangeList[0] = productsProducedDatesRangeList.first;
            producedDateRangeList[1] = productsProducedDatesRangeList.last;
          }
          // if (producedDateRangeList[0] != 0) {
          //   _startProducedDateController.text =
          //       "${producedDateRangeList[0].day}/${producedDateRangeList[0].month}/${producedDateRangeList[0].year}";
          // } else {
          //   producedDateRangeList[0] = productsProducedDatesList.first;
          //   _startProducedDateController.text =
          //       "${productsProducedDatesList.first.day}/${productsProducedDatesList.first.month}/${productsProducedDatesList.first.year}";
          // }

          // if (producedDateRangeList[1] != 0) {
          //   _endProducedDateController.text =
          //       "${availableFromDateRangeList[1].day}/${availableFromDateRangeList[1].month}/${availableFromDateRangeList[1].year}";
          // } else {
          //   producedDateRangeList[1] = productsProducedDatesList.last;
          //   _endProducedDateController.text =
          //       "${productsProducedDatesList.last.day}/${productsProducedDatesList.last.month}/${productsProducedDatesList.last.year}";
          // }
        }
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  //available from dates
  late Uri getProductAvailableDatesUrl;
  String startDateDisplay = '', endDateDisplay = '';
  List<DateTime> productsAvailableDatesRangeList = [];

  void getProductsAvailableFromDatesList() {
    http.get(
      getProductAvailableDatesUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getProductAvailableDatesResp = json.decode(response.body);
        logger.d(getProductAvailableDatesResp);
        if (getProductAvailableDatesResp['message'] ==
            "Products available from dates received") {
          // for (int i = 0;
          //     i < getProductAvailableDatesResp['availableFromDatesRange'].length;
          //     i++) {
          if (getProductAvailableDatesResp['availableFromDatesRange'].length >
              0) {
            productsAvailableDatesRangeList.add(
              DateTime.parse(
                getProductAvailableDatesResp['availableFromDatesRange'][0]
                    ['minAvailDate'],
              ).toLocal(),
            );
            productsAvailableDatesRangeList.add(
              DateTime.parse(
                getProductAvailableDatesResp['availableFromDatesRange'][0]
                    ['maxAvailDate'],
              ).toLocal(),
            );
            availableFromDateRangeList[0] =
                productsAvailableDatesRangeList.first;
            availableFromDateRangeList[1] =
                productsAvailableDatesRangeList.last;
          }
          // if (availableFromDateRangeList[0] != 0) {
          //   _startAvailableDateController.text =
          //       "${availableFromDateRangeList[0].day}/${availableFromDateRangeList[0].month}/${availableFromDateRangeList[0].year}";
          // } else {
          //   availableFromDateRangeList[0] = productsAvailableDatesList.first;
          //   _startAvailableDateController.text =
          //       "${productsAvailableDatesList.first.day}/${productsAvailableDatesList.first.month}/${productsAvailableDatesList.first.year}";
          // }

          // if (availableFromDateRangeList[1] != 0) {
          //   _endAvailableDateController.text =
          //       "${availableFromDateRangeList[1].day}/${availableFromDateRangeList[1].month}/${availableFromDateRangeList[1].year}";
          // } else {
          //   availableFromDateRangeList[1] = productsAvailableDatesList.last;
          //   _endAvailableDateController.text =
          //       "${productsAvailableDatesList.last.day}/${productsAvailableDatesList.last.month}/${productsAvailableDatesList.last.year}";
          // }
        }
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
    locationsList.clear();
    getProductLocationsUrl = Uri.http(
      authority,
      'api/common/getProductLocationList',
      {"searchTerm": widget.searchTerm},
    );
    getProductProducedDatesUrl = Uri.http(
      authority,
      'api/common/getProductProducedDatesList',
      {"searchTerm": widget.searchTerm},
    );
    getProductAvailableDatesUrl = Uri.http(
      authority,
      'api/common/getProductAvailableDatesList',
      {"searchTerm": widget.searchTerm},
    );
    getProductPriceRangeUrl = Uri.http(
      authority,
      'api/common/getProductPriceList',
      {"searchTerm": widget.searchTerm},
    );
    getProductsLocationsList();
    getProductsPriceRangeList();
    getProductsProducedDatesList();
    getProductsAvailableFromDatesList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
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
                "Filter by",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              height: 0,
              // indent: 60,
              // endIndent: 60,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: NavigationRail(
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: const Color.fromARGB(100, 62, 178, 66),
                    backgroundColor: const Color.fromARGB(20, 17, 107, 78),
                    onDestinationSelected: (value) {
                      setState(() {
                        _filterSelectedIndex = value;
                      });
                    },
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.location_city),
                        label: Text("Location"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.money),
                        label: Text("Price"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.date_range),
                        label: SizedBox(
                          width: 75,
                          child: Text(
                            "Produced date",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.event_available),
                        label: SizedBox(
                          width: 75,
                          child: Text(
                            "Available from date",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    selectedIndex: _filterSelectedIndex,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: buildPages(
                      filterSelectedIndex: _filterSelectedIndex,
                      searchTerm: widget.searchTerm,
                      locationAllResceived: productsLocationsList,
                      productsPriceRangeReceived: productsPriceRangeList,
                      prodDateReceived: productsProducedDatesRangeList,
                      availableFromDateReceived:
                          productsAvailableDatesRangeList,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 25.0,
            bottom: 25,
          ),
          child: FilledButton(
            style: FilledButton.styleFrom(
              visualDensity: const VisualDensity(horizontal: 1, vertical: 1),
              // backgroundColor: const Color.fromARGB(255, 44, 81, 57),
              // foregroundColor: Colors.white,
            ),
            child: const Text(
              "Show Results",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.filterFunc(widget.searchTerm);
            },
          ),
        ),
      ],
    );
  }
}

Widget buildPages(
    {filterSelectedIndex,
    searchTerm,
    locationAllResceived,
    productsPriceRangeReceived,
    prodDateReceived,
    availableFromDateReceived}) {
  if (filterSelectedIndex == 1) {
    return BuyerFilterByPricePage(
      searchTerm: searchTerm,
      priceRange: productsPriceRangeReceived,
    );
  } else if (filterSelectedIndex == 2) {
    return BuyerFilterByProducedDatePage(
      searchTerm: searchTerm,
      productsProducedDatesList: prodDateReceived,
    );
  } else if (filterSelectedIndex == 3) {
    return BuyerFilterByAvailableFromDatePage(
      searchTerm: searchTerm,
      productsAvailableDatesList: availableFromDateReceived,
    );
  }
  return BuyerFilterByLocationPage(
    searchTerm: searchTerm,
    productsLocationsList: locationAllResceived,
  );
}

// void getLocationsList(List filterLocationsList) {
//   logger.d("getLocationsList : $filterLocationsList");
//   filetrWidgetLocationsList = filterLocationsList;
// }

// void getPriceRangeList(List filterPriceRangeList) {
//   logger.d("getPriceRangeList : $filterPriceRangeList");
//   filetrWidgetPriceRangeList = filterPriceRangeList;
// }

// void getProducedDateList(List filterProducedDateList) {
//   logger.d("getProducedDateList : $filterProducedDateList");
//   filetrWidgetProducedDateList = filterProducedDateList;
// }

// void getAvailableFromDateList(List filterAvailableFromDateList) {
//   logger.d("getAvailableFromDateList : $filterAvailableFromDateList");
//   filetrWidgetAvailableFromDateList = filterAvailableFromDateList;
// }
