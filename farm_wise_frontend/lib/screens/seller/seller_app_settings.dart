import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/user_details_provider.dart';

class SellerAppSettingsScreen extends StatefulWidget {
  const SellerAppSettingsScreen({super.key});

  @override
  State<SellerAppSettingsScreen> createState() =>
      _SellerAppSettingsScreenState();
}

class _SellerAppSettingsScreenState extends State<SellerAppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "App Settings",
        ),
      ),
      body: InkWell(
        onTap: () {
          debugPrint("logout tapped");
          SharedPreferences.getInstance().then((value) {
            value.remove('token');
            value.remove('userId');
            value.remove('userType');
            value.remove('mobile');
            value.remove('userName');
            setState(() {
              loggedInUserDetails.userId = '';
              loggedInUserDetails.mobile = '';
              loggedInUserDetails.userName = '';
              loggedInUserAuthToken = '';
            });
          }).then((value) {
            context.go('/');
          });
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
                  "Logout",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
                Expanded(
                  child: SizedBox(
                    width: 15,
                  ),
                ),
                Icon(
                  Icons.logout,
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
    );
  }
}
