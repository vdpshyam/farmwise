import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:farm_wise_frontend/providers/https_provider.dart';

import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';

class BuyerPaymentSettingsScreen extends StatefulWidget {
  const BuyerPaymentSettingsScreen({super.key});

  @override
  State<BuyerPaymentSettingsScreen> createState() =>
      _BuyerPaymentSettingsScreenState();
}

class _BuyerPaymentSettingsScreenState
    extends State<BuyerPaymentSettingsScreen> {
  final _razorpay = Razorpay();
  bool isLoading = true;
  int creditAmount = 0,
      transactionsLeft = 0,
      freeTransactionsLeft = 0,
      paidTransactionsLeft = 0;
  DateTime lastSubscribedOn = DateTime.now();

  void getSubscriptionDetails() {
    var getSubscriptionDetailsUrl = Uri.https(
      authority,
      'api/payment/getSubscriptionDetails',
      {
        "userId": loggedInUserDetails.userId,
      },
    );
    http.get(
      getSubscriptionDetailsUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var getSubscriptionDetailsResp = json.decode(response.body);
        if (getSubscriptionDetailsResp["message"] ==
            'Subcription details found') {
          setState(() {
            creditAmount = getSubscriptionDetailsResp["subscriptionDetails"]
                ["creditAmount"];
            transactionsLeft = getSubscriptionDetailsResp["subscriptionDetails"]
                    ["transactionsLeft"] +
                1;
            lastSubscribedOn = DateTime.parse(
                getSubscriptionDetailsResp["subscriptionDetails"]["updatedAt"]);
            paidTransactionsLeft = (transactionsLeft / 4).ceil();
            freeTransactionsLeft = transactionsLeft - paidTransactionsLeft;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        final snackBar = SnackBar(
          content: const Text(
            'Something went wrong. Could not fetch subscription details. Try again later.',
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

  void paymentHandler() {
    Navigator.of(context).push(
      PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        },
      ),
    );
    var orderUrl = Uri.https(authority, 'api/payment/order');
    http.get(orderUrl, headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'}).then(
        (response) {
      debugPrint("Status code : ${response.statusCode}");
      var orderResp = json.decode(response.body);
      // debugPrint(orderResp);

      var options = {
        'key': 'rzp_test_Vb9oNbZ96lAoUN',
        // 'amount': 50000, //in the smallest currency sub-unit.
        'name': 'FarmWise',
        'order_id': orderResp["id"], // Generate order_id using Orders API
        'description': 'Pay for B2B Credits',
        'theme': {
          'color': "#1b9c73",
        },
      };
      Navigator.of(context).pop();
      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getSubscriptionDetails();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    getSubscriptionDetails();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Settings",
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(252, 236, 238, 230),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Current Credit Amount : ",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Rs. $creditAmount",
                                  style: const TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 30,
                              endIndent: 50,
                              indent: 50,
                            ),
                            const Text(
                              "Transactions left : ",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Free",
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "$freeTransactionsLeft",
                                      style: const TextStyle(
                                        fontSize: 19,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      "Paid",
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "$paidTransactionsLeft",
                                      style: const TextStyle(
                                        fontSize: 19,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: Text(
                              "Last Subscribed on : ${lastSubscribedOn.toLocal().day}/${lastSubscribedOn.toLocal().month}/${lastSubscribedOn.toLocal().year}",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: FilledButton(
                                onPressed: () {
                                  // paymentHandler();
                                },
                                child: const Text(
                                  "Subscribe",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text(
                      //   "Bank Account",
                      //   style: TextStyle(
                      //     fontSize: 25,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Subscription Plans : ",
                          //   style: TextStyle(
                          //     fontSize: 19,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          // Text(
                          //   "We offer various subscription plans with different features.",
                          //   style: TextStyle(
                          //     fontSize: 17,
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Subscription Plans Details : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Minimum renewal amount should be more than Rs.400 and get the 80 transcations.We deduced trascation charge for every 4th transaction and initial 3 transaction are free of cost.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Payment Methods : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "We accept [credit/debit cards, PayPal, etc.] as valid payment methods.Payment details are securely processed through our payment gateway.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Taxes : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Applicable taxes will be added to subscription fees as required by local regulations.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Cancellations : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Once payment done for the credit, it can not be cancelled.Subscribers cannot cancel the transaction once it proceeded.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Refunds : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Refunds are not provided for subscription amounts.Refunds may be considered in exceptional cases at our discretion.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Data Security : ",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "All payment information is encrypted and handled securely according to industry standards.We do not store complete payment information on our servers.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Contact Information : ",
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "For any payment-related inquiries or concerns, please contact our support team at [admin@farm_wise_frontend.com/+0431 78787878].",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                      // Text(
                      //   "Union bank of India : *1234",
                      //   style: TextStyle(
                      //     fontSize: 22,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      // Text(
                      //   "UPI Id : seller@okicici",
                      //   style: TextStyle(
                      //     fontSize: 23,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      // Text(
                      //   "Phone linked with bank account for UPI : ",
                      //   style: TextStyle(
                      //     fontSize: 25,
                      //   ),
                      // ),
                      // Text(
                      //   "9876543210",
                      //   style: TextStyle(
                      //     fontSize: 22,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
