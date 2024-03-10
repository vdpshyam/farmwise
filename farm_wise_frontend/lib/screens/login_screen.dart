import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farm_wise_frontend/models/user.dart';
import 'package:farm_wise_frontend/providers/https_provider.dart';
import 'package:themed/themed.dart';
import '../providers/user_details_provider.dart';
import 'loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _userPhoneController;
  late TextEditingController _passwordController;
  bool _hidePassword = true;

  // late String? passwordCheckVal;
  late FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();

  final Uri authUrl = Uri.http(
    authority,
    'api/common/auth',
  );

  final Uri getUserDetailsUrl = Uri.http(
    authority,
    'api/common/getUserDetails',
  );

  void login() {
    try {
      Navigator.of(context).push(PageRouteBuilder(
          barrierColor: const Color.fromARGB(91, 158, 158, 158),
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return const LoadingScreen();
          }));
      var enteredDetails = {
        "mobile": _userPhoneController.text,
        "password": _passwordController.text,
      };
      // loginAuth(enteredDetails);
      var data = json.encode(enteredDetails);
      http
          .post(authUrl,
              headers: {'Content-Type': 'application/json'}, body: data)
          .then(
        (response) async {
          // Navigator.of(context).pop();
          if (response.statusCode == 200) {
            var loginAuthResp = json.decode(response.body);
            if (loginAuthResp['msg'] == 'Authenticated successfully') {
              final SharedPreferences pref =
                  await SharedPreferences.getInstance();
              pref.setString("token", loginAuthResp["token"]);
              pref.setString("userId", loginAuthResp["userId"]);
              pref.setString("mobile", loginAuthResp["resdata"]["mobile"]);
              pref.setString("userType", loginAuthResp["resdata"]["userType"]);
              pref.setString("userName", loginAuthResp["resdata"]["userName"]);
              var authToken = loginAuthResp["token"];
              final Uri getUserDetailsUrl = Uri.http(
                authority,
                'api/common/getUserDetails',
                {"id": loginAuthResp['userId']},
              );
              http.get(getUserDetailsUrl, headers: {
                'Authorization': authToken,
                'Content-Type': 'application/json'
              }).then((response) {
                //***
                // String? finalUserType, finalAuthToken;
                var obtainedAuthTken = pref.getString('token');
                // var obtainedUserType = pref.getString("userType");
                var obtainerUserId = pref.getString('userId');
                var obtainerMobile = pref.getString('mobile');
                var obtainedUserName = pref.getString('userName');

                setState(() {
                  // finalUserType = obtainedUserType;
                  // finalAuthToken = obtainedAuthTken;
                  loggedInUserDetails.userId = obtainerUserId!;
                  loggedInUserDetails.mobile = obtainerMobile!;
                  loggedInUserDetails.userName = obtainedUserName!;
                  loggedInUserAuthToken = obtainedAuthTken!;
                });
                //***
                var getUserDetailsResp = json.decode(response.body);
                // debugPrint(getUserDetailsResp['userDetails']);
                loggedInUserDetails = User(
                    userId: getUserDetailsResp['userDetails']['_id'],
                    userName: getUserDetailsResp['userDetails']['userName'],
                    avatarUrl: getUserDetailsResp['userDetails']['avatarUrl'] ?? '',
                    mobile: getUserDetailsResp['userDetails']['mobile'],
                    userType: getUserDetailsResp['userDetails']['userType'],
                    email: getUserDetailsResp['userDetails']['email'],
                    houseNoStreetName: getUserDetailsResp['userDetails']
                        ['houseNoStreetName'],
                    locality: getUserDetailsResp['userDetails']['locality'],
                    city: getUserDetailsResp['userDetails']['city'],
                    state: getUserDetailsResp['userDetails']['state'],
                    pincode: getUserDetailsResp['userDetails']['pincode'],
                    ratings: getUserDetailsResp['userDetails']['ratings'],
                    verifiedProfile: getUserDetailsResp['userDetails']
                        ['verifiedProfile'],
                    verifyMobile: getUserDetailsResp['userDetails']
                        ['verifyMobile'],
                    ratedUser: getUserDetailsResp['userDetails']['ratedUser'],
                    favoriteProducts: getUserDetailsResp['userDetails']
                        ['favoriteProducts']);
                if (getUserDetailsResp['userDetails']['userType'] == 'Farmer') {
                  context.go("/seller_home_screen");
                } else if (getUserDetailsResp['userDetails']['userType'] ==
                    'Wholesaler') {
                  context.go("/buyer_home_screen");
                }
                debugPrint("Login Done");
              });
            } else if (loginAuthResp['msg'] == "Invalid Credentials") {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "Invalid login details",
                    ),
                    content: const Text(
                      "Please check the entered details and try again.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("okay"),
                      ),
                    ],
                  );
                },
              );
            } else if (loginAuthResp['msg'] == "User doesn't exist") {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      "User doesn't exist",
                    ),
                    content: const Text(
                      "Please check the entered details and try again.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("okay"),
                      ),
                    ],
                  );
                },
              );
              debugPrint("Login Error");
            }
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Couldn't login",
                  ),
                  content:
                      const Text("Something went wrong.Please try again later"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("okay"),
                    ),
                  ],
                );
              },
            );
          }
        },
      );
    } catch (error) {
      debugPrint("login error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong.Try again later'),
          action: SnackBarAction(
            label: 'okay',
            onPressed: () {
              // Code to execute.
            },
          ),
        ),
      );
    }
  }

  // Map<String, dynamic> loginAuthResp = {}, getUserDetailsResp = {};

  // void loginAuth(enteredDetails) async {
  //   var data = json.encode(enteredDetails);
  //   var response = await http.post(authUrl,
  //       headers: {'Content-Type': 'application/json'}, body: data);
  //   loginAuthResp = json.decode(response.body);
  // }

  // void getUserDetails(userId) async {
  //   final Uri getUserDetailsUrl = Uri.http(
  //     authority,
  //     'api/common/getUserDetails',
  //     {"id": userId},
  //   );
  //   var response = await http
  //       .get(getUserDetailsUrl, headers: {'Content-Type': 'application/json'});
  //   getUserDetailsResp = json.decode(response.body);
  //   print(getUserDetailsResp['userDetails']);
  // }

  @override
  void initState() {
    super.initState();
    _userPhoneController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _userPhoneController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 242, 255, 243),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ChangeColors(
              // hue: 0.55,
              brightness: -0.2,
              saturation: 1,
              child: Image.asset(
                'lib/assets/images/background2.jpg',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.3),
                filterQuality: FilterQuality.low,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                // height: 240,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 140,bottom: 50.0),
                  //   child: Text(
                  //     "FarmWise",
                  //     style: TextStyle(
                  //       fontSize: 50,
                  //       letterSpacing: 5,
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Image.asset(
                      'lib/assets/images/logo2.png',
                      height: 240,
                    ),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 100.0, bottom: 50),
                  //   child: Text(
                  //     "farm_wise_frontend",
                  //     style: TextStyle(
                  //       fontSize: 50,
                  //       letterSpacing: 5,
                  //     ),
                  //   ),
                  // ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50.0),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 40,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _userPhoneController,
                              autofocus: true,
                              onFieldSubmitted: (value) =>
                                  _passwordFocusNode.requestFocus(),
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                icon: Icon(
                                  Icons.account_circle,
                                  color: Color.fromARGB(255, 13, 95, 69),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                // labelStyle: TextStyle(
                                //   backgroundColor: Color.fromARGB(255, 255, 255, 255),
                                // ),
                                labelText: ' Phone Number',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length != 10) {
                                  return 'Please enter a valid Phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                  child: Icon(
                                    _hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.password,
                                  color: Color.fromARGB(255, 13, 95, 69),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Password',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 7) {
                                  return 'Password must be atleast 7 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 240.0, top: 20),
                            child: FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 13, 95, 69),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                debugPrint("Login from Login page");
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(200, 13, 95, 69),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    // Navigator.of(context).pushReplacement(
                                    //   MaterialPageRoute(
                                    //     builder: (context) {
                                    //       return const SignupScreen();
                                    //     },
                                    //   ),
                                    // );
                                    context.go("/signup_screen");
                                  },
                                );
                              },
                              child: const Text(
                                "Go to Sign Up Page",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
