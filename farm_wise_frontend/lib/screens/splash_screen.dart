import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_wise_frontend/providers/user_details_provider.dart';
// import 'package:farm_wise_frontend/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

String? finalUserType, finalAuthToken;

class _SplashScreenState extends State<SplashScreen> {
  Future checkAuthDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    var obtainedAuthTken = pref.getString('token');
    var obtainedUserType = pref.getString("userType");
    var obtainerUserId = pref.getString('userId');
    var obtainerMobile = pref.getString('mobile');
    var obtainedUserName = pref.getString('userName');

    setState(() {
      finalUserType = obtainedUserType;
      finalAuthToken = obtainedAuthTken;
      loggedInUserDetails.userId = obtainerUserId!;
      loggedInUserDetails.mobile = obtainerMobile!;
      loggedInUserDetails.userName = obtainedUserName!;
      loggedInUserAuthToken = obtainedAuthTken!;
    });
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   var status = prefs.getBool('isLoggedIn') ?? false;
    //   print(status);
    //   if (status) {
    //     Navigation.pushReplacement(context, "/Home");
    //   } else {
    //     Navigation.pushReplacement(context, "/Login");
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      checkAuthDetails().whenComplete(() async {
        if (finalAuthToken != null) {
          if (finalUserType == "Wholesaler") {
            context.go("/buyer_home_screen");
          } else if (finalUserType == "Farmer") {
            context.go("/seller_home_screen");
          }
        } else {
          context.go('/login_screen');
        }
        debugPrint("checkAuthDetails Complete");
        // context.go('/login_screen');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Center(
          child: Image.asset(
            'lib/assets/images/logo2.png',
            height: 200,
          ),
          // ChangeColors(
          //   brightness: -0.1,
          //   saturation: 1,
          //   child: Image.asset(
          //     'lib/assets/images/logo2.png',
          //     height: 240,
          //   ),
          // ),
        ),
      ),
    );
  }
}
