import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/providers/user_details_provider.dart';

import '../../providers/https_provider.dart';
import '../loading_screen.dart';
import 'buyer_order_details_screen.dart';

class BuyerPlaceOrderScreen extends StatefulWidget {
  const BuyerPlaceOrderScreen({
    super.key,
    required this.productName,
    required this.sellerName,
    required this.sellerMobile,
    required this.quantityUnit,
    required this.basePrice,
    required this.quantityPerLot,
    required this.minNoLot,
    required this.productImageUrl,
    required this.productId,
  });

  final String productName,
      productId,
      sellerName,
      sellerMobile,
      quantityUnit,
      productImageUrl;
  final int basePrice, quantityPerLot, minNoLot;

  @override
  State<BuyerPlaceOrderScreen> createState() => _BuyerPlaceOrderScreenState();
}

class _BuyerPlaceOrderScreenState extends State<BuyerPlaceOrderScreen> {
  late Uri createOrderUrl;

  DateTime reqOnorBefore = DateTime.now(), expectResponseBy = DateTime.now();
  bool reqOnorBeforeNotSelected = true,
      expectResponseByNotSelected = true,
      paymentModeNotSelected = true;
  late double totalOrderValue;
  late String selectedPaymentMode;

  late TextEditingController _buyerQuotePriceCotroller;
  late TextEditingController _buyerNoOfLotsCotroller;

  @override
  void initState() {
    super.initState();
    _buyerQuotePriceCotroller = TextEditingController(
      text: widget.basePrice.toString(),
    );
    _buyerNoOfLotsCotroller = TextEditingController(
      text: widget.minNoLot.toString(),
    );
    totalOrderValue = double.parse((int.parse(_buyerQuotePriceCotroller.text) *
            int.parse(_buyerNoOfLotsCotroller.text) *
            widget.quantityPerLot)
        .toString());
    createOrderUrl = Uri.http(authority, 'api/common/createOrder');
  }

  @override
  void dispose() {
    super.dispose();
    _buyerQuotePriceCotroller.dispose();
    _buyerNoOfLotsCotroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
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
                      height: 100,
                      width: 150,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                widget.productImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName,
                          ),
                          Text(
                            "Base price : ${widget.basePrice}/${widget.quantityUnit}",
                          ),
                          Text(
                            "Seller : ${widget.sellerName}",
                          ),
                          // Text(
                          //   "Seller Ph. : ${widget.sellerMobile}",
                          // ),
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
                  Text("Min no. of lot(s): ${widget.minNoLot}"),
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
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextField(
                            controller: _buyerQuotePriceCotroller,
                            onChanged: (value) {
                              totalOrderValue = double.parse((int.parse(value) *
                                      int.parse(_buyerNoOfLotsCotroller.text) *
                                      widget.quantityPerLot)
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
                                  color: Color.fromARGB(163, 158, 158, 158),
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
                          "  /${widget.quantityUnit}",
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
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: TextField(
                            controller: _buyerNoOfLotsCotroller,
                            onChanged: (value) {
                              totalOrderValue = double.parse(
                                  (int.parse(_buyerQuotePriceCotroller.text) *
                                          int.parse(value) *
                                          widget.quantityPerLot)
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
                                  color: Color.fromARGB(163, 158, 158, 158),
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
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  reqOnorBefore = value;
                                  reqOnorBeforeNotSelected = false;
                                });
                              }
                            });
                          },
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(163, 158, 158, 158),
                                width: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: reqOnorBeforeNotSelected
                                  ? const Text(
                                      "Select date",
                                    )
                                  : Text(
                                      "${reqOnorBefore.toLocal().day}/${reqOnorBefore.toLocal().month}/${reqOnorBefore.toLocal().year}",
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
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  expectResponseBy = value;
                                  expectResponseByNotSelected = false;
                                });
                              }
                            });
                          },
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(163, 158, 158, 158),
                                width: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: expectResponseByNotSelected
                                  ? const Text(
                                      "Select date",
                                    )
                                  : Text(
                                      "${expectResponseBy.toLocal().day}/${expectResponseBy.toLocal().month}/${expectResponseBy.toLocal().year}",
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
                          width: MediaQuery.of(context).size.width * 0.4,
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
                                    contentPadding: const EdgeInsets.all(0),
                                    title: const Text(
                                      "Choose payment mode",
                                      style: TextStyle(fontSize: 20),
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
                                                selectedPaymentMode = 'COD';
                                                paymentModeNotSelected = false;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Row(
                                              children: [
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Text(
                                                  "Cash on delivery",
                                                  style:
                                                      TextStyle(fontSize: 16),
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
                                                selectedPaymentMode = 'UPI';
                                                paymentModeNotSelected = false;
                                              });
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
                                                    fontSize: 16,
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
                                                selectedPaymentMode = 'CARD';
                                                paymentModeNotSelected = false;
                                              });
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
                                                    fontSize: 16,
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
                                  color:
                                      const Color.fromARGB(163, 158, 158, 158),
                                  width: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: paymentModeNotSelected
                                    ? const Text(
                                        "Select mode",
                                      )
                                    : Text(
                                        selectedPaymentMode,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 30,
                    indent: 10,
                    endIndent: 10,
                  ),
                  calculateTotalOrderValue(totalOrderValue),
                  const Divider(
                    height: 30,
                    indent: 10,
                    endIndent: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30, bottom: 50),
              child: SizedBox(
                width: double.maxFinite,
                child: FilledButton.icon(
                  onPressed: () {
                    if (reqOnorBeforeNotSelected == false &&
                        expectResponseByNotSelected == false &&
                        paymentModeNotSelected == false) {
                      Navigator.of(context).push(PageRouteBuilder(
                          barrierColor: const Color.fromARGB(91, 158, 158, 158),
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) {
                            return const LoadingScreen();
                          }));
                      http
                          .post(
                        createOrderUrl,
                        headers: {
                          'Authorization': loggedInUserAuthToken,
                          'Content-Type': 'application/json'
                        },
                        body: json.encode({
                          "sellerMobile": widget.sellerMobile,
                          "buyerId": loggedInUserDetails.userId,
                          "productId": widget.productId,
                          "basePrice": widget.basePrice,
                          "dealPrice":
                              int.parse(_buyerQuotePriceCotroller.text),
                          "orderQtyLots":
                              int.parse(_buyerNoOfLotsCotroller.text),
                          "orderValue": totalOrderValue,
                          "isOrderAccepted": false,
                          "paymentMode": selectedPaymentMode,
                          "halfPaymentDone": false,
                          "fullPaymentDone": false,
                          "isClosed": false,
                          "closedOn": "",
                          "requiredOnOrBefore":
                              reqOnorBefore.toUtc().toString(),
                          "expectingResponseBefore":
                              expectResponseBy.toUtc().toString(),
                          // "buyerClosedOn": DateTime.now().toUtc().toString(),
                          "isBuyerClosed": false,
                          "isSellerClosed": false,
                          // "sellerClosedOn": DateTime.now().toUtc().toString(),
                        }),
                      )
                          .then((response) {
                        // debugPrint(response.body);
                        Navigator.of(context).pop();
                        var placeOrderResp = json.decode(response.body);
                        if (placeOrderResp["message"] == "Order placed") {
                          // debugPrint(placeOrderResp["orderDetails"]["_id"]);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  "Order successfully placed",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) {
                                          return BuyerOrderDetailScreen(
                                            orderId:
                                                placeOrderResp["orderDetails"]
                                                    ["_id"],
                                            refreshOrdersListFunc: () {},
                                          );
                                        },
                                      ));
                                    },
                                    child: const Text(
                                      "See order details",
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "okay",
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    } else {
                      final snackBar = SnackBar(
                        content: const Text('Please fill all the details'),
                        action: SnackBarAction(
                          label: 'Okay',
                          onPressed: () {},
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  label: const Text(
                    "Confirm and place order",
                  ),
                  icon: const Icon(Icons.done),
                ),
              ),
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
