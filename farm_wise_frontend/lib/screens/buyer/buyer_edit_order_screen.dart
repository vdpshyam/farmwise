import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';

class BuyerEditOrderScreen extends StatefulWidget {
  const BuyerEditOrderScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  State<BuyerEditOrderScreen> createState() => _BuyerEditOrderScreenState();
}

class _BuyerEditOrderScreenState extends State<BuyerEditOrderScreen> {
  late Uri getOrderDetailsUrl;
  bool isLoading = true, anyDataChanged = false;

  // DateTime reqOnorBefore = DateTime.now(), expectResponseBy = DateTime.now();
  // bool reqOnorBeforeNotSelected = true,
  //     expectResponseByNotSelected = true,
  //     paymentModeNotSelected = true;
  late double totalOrderValue;
  // late String selectedPaymentMode;

  late TextEditingController _buyerQuotePriceCotroller;
  late TextEditingController _buyerNoOfLotsCotroller;

  late String orderId,
      paymentMode,
      sellerName,
      sellerMobile,
      productName,
      quantityUnit,
      productImageUrl;
  late DateTime closedOn, requiredOnOrBefore, expectingResponseBefore;
  late int dealPrice,
      orderValue,
      orderQtyLots,
      basePrice,
      minNoLot,
      quantityPerLot;

  void getOrderDetails() {
    http.get(getOrderDetailsUrl, headers: {
      'Authorization': loggedInUserAuthToken,
      'Content-Type': 'application/json'
    }).then((response) {
      var getOrderDetailsResp = json.decode(response.body);
      if (getOrderDetailsResp["message"] == "Orders details recieved") {
        var orderDetails = getOrderDetailsResp["orderDetails"];
        if (orderDetails.length > 0) {
          orderId = orderDetails[0]["_id"];
          paymentMode = orderDetails[0]["paymentMode"];
          dealPrice = orderDetails[0]["dealPrice"];
          orderValue = orderDetails[0]["orderValue"];
          orderQtyLots = orderDetails[0]["orderQtyLots"];
          requiredOnOrBefore =
              DateTime.parse(orderDetails[0]["requiredOnOrBefore"]);
          expectingResponseBefore =
              DateTime.parse(orderDetails[0]["expectingResponseBefore"]);
        }

        if (orderDetails[0]["sellerDetails"].length > 0) {
          sellerName = orderDetails[0]["sellerDetails"][0]["userName"];
          sellerMobile = orderDetails[0]["sellerDetails"][0]["mobile"];
        }

        if (orderDetails[0]["productDetails"].length > 0) {
          productName = orderDetails[0]["productDetails"][0]["productName"];
          quantityUnit = orderDetails[0]["productDetails"][0]["quantityUnit"];
          productImageUrl =
              orderDetails[0]["productDetails"][0]["productImages"][0];
          basePrice = orderDetails[0]["productDetails"][0]["basePrice"];
          minNoLot = orderDetails[0]["productDetails"][0]["minNoLot"];
          quantityPerLot =
              orderDetails[0]["productDetails"][0]["quantityPerLot"];
        }
      }
    }).then((value) {
      _buyerQuotePriceCotroller = TextEditingController(
        text: dealPrice.toString(),
      );
      _buyerNoOfLotsCotroller = TextEditingController(
        text: orderQtyLots.toString(),
      );
      totalOrderValue = double.parse(
          (int.parse(_buyerQuotePriceCotroller.text) *
                  int.parse(_buyerNoOfLotsCotroller.text) *
                  quantityPerLot)
              .toString());
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _buyerQuotePriceCotroller = TextEditingController();
    _buyerNoOfLotsCotroller = TextEditingController();
    getOrderDetailsUrl = Uri.https(
      authority,
      'api/common/getOrderDetails',
      {"id": widget.orderId},
    );
    getOrderDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _buyerQuotePriceCotroller.dispose();
    _buyerNoOfLotsCotroller.dispose();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                        top: BorderSide(
                          width: 0.5,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                        left: BorderSide(
                          width: 0.5,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                        right: BorderSide(
                          width: 0.5,
                          color: Color.fromARGB(255, 206, 206, 206),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 160,
                            width: 150,
                            child: Column(
                              children: [
                                Center(
                                  child: Image.network(
                                    productImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SizedBox(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                ),
                                Text(
                                  "Base price : $basePrice/$quantityUnit",
                                ),
                                Text(
                                  "Seller : $sellerName",
                                ),
                                Text(
                                  "Seller Ph. : $sellerMobile",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Min no. of lot(s): $minNoLot"),
                        const Divider(
                          height: 50,
                          indent: 60,
                          endIndent: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                "Quote price : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 85,
                              ),
                              SizedBox(
                                height: 45,
                                width: 150,
                                child: TextField(
                                  controller: _buyerQuotePriceCotroller,
                                  onChanged: (value) {
                                    anyDataChanged = true;
                                    totalOrderValue = double.parse((int.parse(
                                                value) *
                                            int.parse(
                                                _buyerNoOfLotsCotroller.text) *
                                            quantityPerLot)
                                        .toString());
                                    setState(() {
                                      calculateTotalOrderValue(totalOrderValue);
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(163, 158, 158, 158),
                                        width: 0.7,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(14.0),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(14.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                "  /$quantityUnit",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                "No of Lots : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 94,
                              ),
                              SizedBox(
                                height: 45,
                                width: 150,
                                child: TextField(
                                  controller: _buyerNoOfLotsCotroller,
                                  onChanged: (value) {
                                    anyDataChanged = true;
                                    totalOrderValue = double.parse((int.parse(
                                                _buyerQuotePriceCotroller
                                                    .text) *
                                            int.parse(value) *
                                            quantityPerLot)
                                        .toString());
                                    setState(() {
                                      calculateTotalOrderValue(totalOrderValue);
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(163, 158, 158, 158),
                                        width: 0.7,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(14.0),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(14.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                "Required on or before : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: requiredOnOrBefore.toLocal(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        requiredOnOrBefore = value.toUtc();
                                      });
                                      anyDataChanged = true;
                                    }
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          163, 158, 158, 158),
                                      width: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${requiredOnOrBefore.toLocal().day}/${requiredOnOrBefore.toLocal().month}/${requiredOnOrBefore.toLocal().year}",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                "Expecting response by : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate:
                                        expectingResponseBefore.toLocal(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        expectingResponseBefore = value.toUtc();
                                      });
                                      anyDataChanged = true;
                                    }
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          163, 158, 158, 158),
                                      width: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${expectingResponseBefore.toLocal().day}/${expectingResponseBefore.toLocal().month}/${expectingResponseBefore.toLocal().year}",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                "Payment mode : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 64,
                              ),
                              SizedBox(
                                height: 45,
                                width: 150,
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          titlePadding: const EdgeInsets.only(
                                            top: 25,
                                            left: 35,
                                            right: 20,
                                            bottom: 20,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          title: const Text(
                                            "Choose payment mode",
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                width: double.maxFinite,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      paymentMode = 'COD';
                                                    });
                                                    anyDataChanged = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                      Text(
                                                        "Cash on delivery",
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Icon(Icons.money),
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: double.maxFinite,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      paymentMode = 'UPI';
                                                    });
                                                    anyDataChanged = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                      Text(
                                                        "UPI",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Icon(Icons.phone_android),
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: double.maxFinite,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      paymentMode = 'CARD';
                                                    });
                                                    anyDataChanged = true;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                      Text(
                                                        "Credit/Debit card",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Icon(
                                                        Icons.credit_card,
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            163, 158, 158, 158),
                                        width: 0.7,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        paymentMode,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 50,
                          indent: 60,
                          endIndent: 60,
                        ),
                        calculateTotalOrderValue(totalOrderValue),
                        const Divider(
                          height: 50,
                          indent: 60,
                          endIndent: 60,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color.fromARGB(255, 132, 132, 132),
                          ),
                        ),
                        onPressed: () {
                          anyDataChanged = false;
                          Navigator.of(context).pop();
                        },
                        label: const Text(
                          "Discard changes",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (anyDataChanged) {
                            Navigator.of(context).push(PageRouteBuilder(
                                barrierColor:
                                    const Color.fromARGB(91, 158, 158, 158),
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) {
                                  return const LoadingScreen();
                                }));
                            var updateOrderDetailsUrl = Uri.https(
                              authority,
                              'api/common/updateOrderDetails',
                            );
                            http
                                .put(
                              updateOrderDetailsUrl,
                              headers: {
                                'Authorization': loggedInUserAuthToken,
                                'Content-Type': 'application/json'
                              },
                              body: json.encode({
                                "id": orderId,
                                "dealPrice":
                                    int.parse(_buyerQuotePriceCotroller.text),
                                "orderQtyLots":
                                    int.parse(_buyerNoOfLotsCotroller.text),
                                "orderValue": totalOrderValue,
                                "paymentMode": paymentMode,
                                "requiredOnOrBefore":
                                    requiredOnOrBefore.toUtc().toString(),
                                "expectingResponseBefore":
                                    expectingResponseBefore.toUtc().toString()
                              }),
                            )
                                .then((response) {
                              // debugPrint(response.body);
                              Navigator.of(context).pop();
                              var placeOrderResp = json.decode(response.body);
                              if (placeOrderResp["message"] ==
                                  "Order updated") {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Order successfully updated",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "okay",
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            });
                          } else {
                            final snackBar = SnackBar(
                              content:
                                  const Text('No details changed for updation'),
                              action: SnackBarAction(
                                label: 'Okay',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        label: const Text(
                          "Update and place order",
                        ),
                        icon: const Icon(Icons.done),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }

  Row calculateTotalOrderValue(totalOrderValueTemp) {
    return Row(
      children: [
        const Text(
          "Total order value : ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Rs.$totalOrderValueTemp",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
