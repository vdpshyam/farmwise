import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/user_details_provider.dart';

class BuyerAppSettingsScreen extends StatefulWidget {
  const BuyerAppSettingsScreen({super.key});

  @override
  State<BuyerAppSettingsScreen> createState() => _BuyerAppSettingsScreenState();
}

class _BuyerAppSettingsScreenState extends State<BuyerAppSettingsScreen> {
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
            loggedInUserDetails.userId = '';
            loggedInUserDetails.mobile = '';
            loggedInUserDetails.userName = '';
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
    );
  }
}
