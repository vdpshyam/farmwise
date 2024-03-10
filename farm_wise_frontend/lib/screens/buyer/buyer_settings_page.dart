import 'package:flutter/material.dart';

import '../../providers/user_details_provider.dart';
import 'buyer_app_settings.dart';
import 'buyer_orders_history_screen.dart';
import 'buyer_payment_settings_screen.dart';
import 'buyer_profile_settings_screen.dart';
import 'buyer_reviews_screen.dart';

class BuyerSettingsPage extends StatelessWidget {
  const BuyerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 45,
            child: Text(
              "Hello ${loggedInUserDetails.userName}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        InkWell(
          onTap: () {
            debugPrint("Profile and Contact Settings tapped");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const BuyerProfileSettingsScreen(),
              ),
            );
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    "Profile and Contact Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 15,
                    ),
                  ),
                  Icon(
                    Icons.account_circle,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          indent: 100,
          endIndent: 100,
        ),
        InkWell(
          onTap: () {
            debugPrint("Payment Settings tapped");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const BuyerPaymentSettingsScreen(),
              ),
            );
          },
          child: const Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    "Subscription settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 15,
                    ),
                  ),
                  Icon(
                    Icons.payment_rounded,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          indent: 100,
          endIndent: 100,
        ),
        InkWell(
          onTap: () {
            debugPrint("Orders History tapped");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const BuyerOrdersHistoryScreen(),
              ),
            );
          },
          child: const Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    "Orders History",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 15,
                    ),
                  ),
                  Icon(
                    Icons.assignment_outlined,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          indent: 100,
          endIndent: 100,
        ),
        InkWell(
          onTap: () {
            debugPrint("Reviews and Comments tapped");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => const BuyerReviewsScreen(),
              ),
            );
          },
          child: const Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    "Reviews and Comments",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 15,
                    ),
                  ),
                  Icon(
                    Icons.reviews_outlined,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
          indent: 100,
          endIndent: 100,
        ),
        InkWell(
          onTap: () {
            debugPrint("App Settings tapped");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    const BuyerAppSettingsScreen(),
              ),
            );
          },
          child: const Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    "App Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 15,
                    ),
                  ),
                  Icon(
                    Icons.app_settings_alt_rounded,
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const Expanded(
          child: SizedBox(
              // height: 15,
              ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Contact Information : ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                "For any payment-related inquiries or concerns, please contact our support team at [support@farmwise.com/+91 9898989898].",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
