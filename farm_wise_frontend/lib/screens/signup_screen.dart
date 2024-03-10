import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';
import 'package:themed/themed.dart';

import '../providers/https_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class StatesModel {
  String label, name;
  StatesModel({required this.label, required this.name});
}

class CityModel {
  String label, value;
  CityModel({required this.label, required this.value});
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _userPhoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _userEmailController;
  late TextEditingController _userHouseNoStreetNameController;
  late TextEditingController _userLocalityController;
  late TextEditingController _userCityController;
  late TextEditingController _userStateController;
  late TextEditingController _userPincodeController;
  late TextEditingController _userTypeController;

  StatesModel selectedState = StatesModel(label: '', name: '');
  CityModel selectedCity = CityModel(label: '', value: '');

  bool _hidePassword = true, _hideConfirmPassword = true;

  late String? _passwordCheckVal;

  final _formKey = GlobalKey<FormState>();

  late FocusNode _userNameFocusNode;
  late FocusNode _userPhoneFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _userEmailFocusNode;
  late FocusNode _userHouseNoStreetNameFocusNode;
  late FocusNode _userLocalityFocusNode;
  late FocusNode _userCityFocusNode;
  late FocusNode _userStateFocusNode;
  late FocusNode _userPincodeFocusNode;

  final Uri signUpUrl = Uri.http(
    authority,
    'api/common/createuser',
  );

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _userPhoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _userEmailController = TextEditingController();
    _userHouseNoStreetNameController = TextEditingController();
    _userLocalityController = TextEditingController();
    _userCityController = TextEditingController();
    _userStateController = TextEditingController();
    _userPincodeController = TextEditingController();
    _userTypeController = TextEditingController();

    _userNameFocusNode = FocusNode();
    _userPhoneFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _userEmailFocusNode = FocusNode();
    _userHouseNoStreetNameFocusNode = FocusNode();
    _userLocalityFocusNode = FocusNode();
    _userCityFocusNode = FocusNode();
    _userStateFocusNode = FocusNode();
    _userPincodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _userNameController.dispose();
    _userPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userEmailController.dispose();
    _userHouseNoStreetNameController.dispose();
    _userLocalityController.dispose();
    _userCityController.dispose();
    _userStateController.dispose();
    _userPincodeController.dispose();

    _userNameFocusNode.dispose();
    _userPhoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _userEmailFocusNode.dispose();
    _userHouseNoStreetNameFocusNode.dispose();
    _userLocalityFocusNode.dispose();
    _userCityFocusNode.dispose();
    _userStateFocusNode.dispose();
    _userPincodeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  //   padding: EdgeInsets.only(
                  //     top: 50.0,
                  //     bottom: 30,
                  //   ),
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
                      "Sign Up",
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
                              // autofocus: true,
                              controller: _userNameController,
                              onFieldSubmitted: (value) =>
                                  _userPhoneFocusNode.requestFocus(),
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                icon: Icon(
                                  Icons.face_6,
                                  color: Color.fromARGB(255, 13, 95, 69),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Name',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _userPhoneController,
                              focusNode: _userPhoneFocusNode,
                              onFieldSubmitted: (value) =>
                                  _passwordFocusNode.requestFocus(),
                              keyboardType: TextInputType.phone,
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
                                labelText: 'Phone Number',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length != 10) {
                                  return 'Please enter a valid phone number with 10 digits';
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
                              onFieldSubmitted: (value) =>
                                  _confirmPasswordFocusNode.requestFocus(),
                              onChanged: (value) {
                                _passwordCheckVal = value;
                              },
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
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 7 ||
                                    value.trim().length > 14) {
                                  return 'Please enter a valid password with 7 to 14 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              onFieldSubmitted: (value) =>
                                  _userEmailFocusNode.requestFocus(),
                              obscureText: _hideConfirmPassword,
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword;
                                    });
                                  },
                                  child: Icon(
                                    _hideConfirmPassword
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
                                labelText: 'Confirm Password',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 7 ||
                                    value.trim().length > 14) {
                                  return 'Please enter a valid password with 7 to 14 characters';
                                } else if (value.trim() != _passwordCheckVal) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _userEmailController,
                              focusNode: _userEmailFocusNode,
                              onFieldSubmitted: (value) =>
                                  _userHouseNoStreetNameFocusNode
                                      .requestFocus(),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                icon: Icon(
                                  Icons.email,
                                  color: Color.fromARGB(255, 13, 95, 69),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Email',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !EmailValidator.validate(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _userHouseNoStreetNameController,
                              focusNode: _userHouseNoStreetNameFocusNode,
                              onFieldSubmitted: (value) =>
                                  _userLocalityFocusNode.requestFocus(),
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                icon: Icon(
                                  Icons.house,
                                  color: Color.fromARGB(255, 13, 95, 69),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'House No. / Street name',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter valid house no. / street name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: SizedBox(
                                  width: 183,
                                  child: TextFormField(
                                    controller: _userLocalityController,
                                    focusNode: _userLocalityFocusNode,
                                    onFieldSubmitted: (value) =>
                                        _userCityFocusNode.requestFocus(),
                                    decoration: const InputDecoration(
                                      fillColor:
                                          Color.fromARGB(170, 255, 255, 255),
                                      filled: true,
                                      icon: Icon(
                                        Icons.house,
                                        color: Color.fromARGB(255, 13, 95, 69),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'Locality',
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid city';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: SizedBox(
                                  width: 153,
                                  child: TextFormField(
                                    controller: _userStateController,
                                    focusNode: _userStateFocusNode,
                                    readOnly: true,
                                    onTap: () {
                                      List<StatesModel> statesList = [];
                                      var getStatesListUrl = Uri.http(
                                        authority,
                                        'api/common/stateslist',
                                      );
                                      http.get(
                                        getStatesListUrl,
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                      ).then((response) {
                                        if (response.statusCode == 200) {
                                          var statesListResp =
                                              json.decode(response.body);
                                          for (int i = 0;
                                              i < statesListResp["data"].length;
                                              i++) {
                                            statesList.add(
                                              StatesModel(
                                                label: statesListResp["data"][i]
                                                    ["label"],
                                                name: statesListResp["data"][i]
                                                    ["name"],
                                              ),
                                            );
                                          }
                                        }
                                      }).then((value) {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Select State',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Divider(
                                                  indent: 15,
                                                  endIndent: 15,
                                                  height: 5,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                            content: SizedBox(
                                              height: 500,
                                              width: 300,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: statesList.length,
                                                itemBuilder: (context, index) {
                                                  return TextButton(
                                                    onPressed: () {
                                                      debugPrint(
                                                          "${statesList[index].label} : ${statesList[index].name}");
                                                      setState(() {
                                                        _userStateController
                                                                .text =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.label =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.name =
                                                            statesList[index]
                                                                .name;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Expanded(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Center(
                                                          child: Text(
                                                            statesList[index]
                                                                .label,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                    onFieldSubmitted: (value) =>
                                        _userCityFocusNode.requestFocus(),
                                    decoration: const InputDecoration(
                                      fillColor:
                                          Color.fromARGB(170, 255, 255, 255),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'State',
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid state';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: SizedBox(
                                  width: 183,
                                  child: TextFormField(
                                    controller: _userCityController,
                                    focusNode: _userCityFocusNode,
                                    readOnly: true,
                                    onTap: () {
                                      List<CityModel> cityList = [];
                                      var getCityListUrl = Uri.http(
                                          authority,
                                          'api/common/citylistbystate',
                                          {"states": selectedState.name});
                                      http.get(
                                        getCityListUrl,
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                      ).then((response) {
                                        if (response.statusCode == 200) {
                                          var citiesListResp =
                                              json.decode(response.body);
                                          for (int i = 0;
                                              i < citiesListResp["data"].length;
                                              i++) {
                                            cityList.add(
                                              CityModel(
                                                label: citiesListResp["data"][i]
                                                    ["label"],
                                                value: citiesListResp["data"][i]
                                                    ["value"],
                                              ),
                                            );
                                          }
                                        }
                                      }).then((value) {
                                        showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Select City',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Divider(
                                                  indent: 15,
                                                  endIndent: 15,
                                                  height: 5,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                            content: SizedBox(
                                              height: 500,
                                              width: 300,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: cityList.length,
                                                itemBuilder: (context, index) {
                                                  return TextButton(
                                                    onPressed: () {
                                                      debugPrint(
                                                          "${cityList[index].label} : ${cityList[index].value}");
                                                      setState(() {
                                                        _userCityController
                                                                .text =
                                                            cityList[index]
                                                                .label;
                                                        selectedCity.label =
                                                            cityList[index]
                                                                .label;
                                                        selectedCity.value =
                                                            cityList[index]
                                                                .value;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Expanded(
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: Center(
                                                          child: Text(
                                                            cityList[index]
                                                                .label,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                    onFieldSubmitted: (value) =>
                                        _userStateFocusNode.requestFocus(),
                                    decoration: const InputDecoration(
                                      fillColor:
                                          Color.fromARGB(170, 255, 255, 255),
                                      filled: true,
                                      icon: Icon(
                                        Icons.house,
                                        color: Color.fromARGB(255, 13, 95, 69),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'City',
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid city';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: SizedBox(
                                  width: 153,
                                  child: TextFormField(
                                    controller: _userPincodeController,
                                    focusNode: _userPincodeFocusNode,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      fillColor:
                                          Color.fromARGB(170, 255, 255, 255),
                                      filled: true,
                                      // icon: Icon(
                                      //   Icons.house,
                                      //   color: Color.fromARGB(255, 13, 95, 69),
                                      // ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'Pincode',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim().length != 6) {
                                        return 'Please enter a valid pincode';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              maxLines: 1,
                              minLines: 1,
                              controller: _userTypeController,
                              onTap: () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Select Category',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          indent: 15,
                                          endIndent: 15,
                                          height: 5,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            debugPrint("Farmer");
                                            setState(() {
                                              _userTypeController.text =
                                                  "Farmer";
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Expanded(
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Center(
                                                child: Text(
                                                  "Farmer",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            debugPrint("Wholesaler");
                                            setState(() {
                                              _userTypeController.text =
                                                  "Wholesaler";
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Expanded(
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Center(
                                                child: Text(
                                                  "Wholesaler",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(170, 255, 255, 255),
                                filled: true,
                                contentPadding: EdgeInsets.only(left: 20),
                                icon: Text("I'm a"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Select category',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter user type';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 220.0, top: 20),
                            child: FilledButton.tonal(
                              onPressed: () {
                                debugPrint("Sign-up from Sign-up page");
                                if (_formKey.currentState!.validate()) {
                                  var enteredDetails = {
                                    "userName": _userNameController.text,
                                    "mobile": _userPhoneController.text,
                                    "password": _passwordController.text,
                                    "email": _userEmailController.text,
                                    "houseNoStreetName":
                                        _userHouseNoStreetNameController.text,
                                    "locality": _userLocalityController.text,
                                    "city": _userCityController.text,
                                    "state": _userStateController.text,
                                    "pincode":
                                        int.parse(_userPincodeController.text),
                                    "userType": _userTypeController.text,
                                    "avatarUrl": "",
                                    "verifiedProfile": false,
                                    "verifyMobile": false,
                                    "ratings": 0,
                                    "ratedUser": [],
                                    "favoriteProducts": []
                                  };
                                  var data = json.encode(enteredDetails);
                                  // debugPrint(data);
                                  http
                                      .post(signUpUrl,
                                          headers: {
                                            'Content-Type': 'application/json'
                                          },
                                          body: data)
                                      .then(
                                    (response) {
                                      if (response.statusCode == 200) {
                                        var signUpResp =
                                            json.decode(response.body);
                                        // debugPrint(
                                        //     "${response.statusCode} , $signUpResp");
                                        if (signUpResp['msg'] ==
                                            'User credential already exist') {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'User already exist.',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Divider(
                                                      indent: 15,
                                                      endIndent: 15,
                                                      height: 5,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "Please check the entered details, or go to login screen to login to your account",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      context
                                                          .go("/login_screen");
                                                    },
                                                    child: const Text(
                                                      "Go to login screen",
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _userPhoneController
                                                          .text = '';
                                                      _userPhoneFocusNode
                                                          .requestFocus();
                                                    },
                                                    child: const Text(
                                                      "okay",
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else if (signUpResp['msg'] ==
                                            "User Registed successfully") {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'User registeration successful',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Divider(
                                                      indent: 15,
                                                      endIndent: 15,
                                                      height: 5,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "You will now be re-directed to login screen from where you can access your account.",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      context
                                                          .go("/login_screen");
                                                    },
                                                    child: const Text("okay"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        // debugPrint("${response.statusCode}");
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Couldn't signup.",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Divider(
                                                    indent: 15,
                                                    endIndent: 15,
                                                    height: 5,
                                                    color: Colors.black26,
                                                  ),
                                                ],
                                              ),
                                              content: const Text(
                                                  "Something went wrong.Please try again later"),
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
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 13, 95, 69),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 50.0, bottom: 50),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(200, 13, 95, 69),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context.go('/login_screen');
                              },
                              child: const Text(
                                "Go to Login Page",
                                style: TextStyle(
                                  fontSize: 18,
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
