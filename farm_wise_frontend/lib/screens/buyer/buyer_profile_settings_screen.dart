import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

import 'package:farm_wise_frontend/providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../loading_screen.dart';
import 'buyer_password_reset_screen.dart';

class BuyerProfileSettingsScreen extends StatefulWidget {
  const BuyerProfileSettingsScreen({super.key});

  @override
  State<BuyerProfileSettingsScreen> createState() =>
      _BuyerProfileSettingsScreenState();
}

class StatesModel {
  String label, name;
  StatesModel({required this.label, required this.name});
}

class CityModel {
  String label, value;
  CityModel({required this.label, required this.value});
}

class _BuyerProfileSettingsScreenState
    extends State<BuyerProfileSettingsScreen> {
  late bool anyDataChanged, isImageDataChanged;
  late bool isUserDataUpdated;
  late Uri updateUserDetailsUrl;
  bool isLoading = true;

  String avatarUrl = '';
  late TextEditingController _buyerNameController;
  late TextEditingController _buyerPhoneController;
  late TextEditingController _buyerHouseNoStreetNameController;
  late TextEditingController _buyerHouselocalityController;
  late TextEditingController _buyerHouseCityController;
  late TextEditingController _buyerHouseStateController;
  late TextEditingController _buyerHousePincodeController;
  late TextEditingController _buyerEmailAddressController;
  late TextEditingController _buyerPasswordController;
  late TextEditingController _buyerUserTypeController;
  bool isVerifiedProfile = false;
  StatesModel selectedState = StatesModel(label: '', name: '');
  CityModel selectedCity = CityModel(label: '', value: '');

  File? image;

  void getUserDetails() {
    var userDetailsUrl = Uri.http(authority, 'api/common/getUserDetails', {
      "id": loggedInUserDetails.userId,
    });

    http.get(
      userDetailsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var userDetailsResp = json.decode(response.body);
        if (userDetailsResp["message"] == "User found") {
          setState(() {
            avatarUrl = userDetailsResp["userDetails"]["avatarUrl"];
            isVerifiedProfile = userDetailsResp["userDetails"]["verifiedProfile"];
          });
          _buyerNameController = TextEditingController(
              text: userDetailsResp["userDetails"]["userName"]);
          _buyerPhoneController = TextEditingController(
              text: userDetailsResp["userDetails"]["mobile"]);
          _buyerHouseNoStreetNameController = TextEditingController(
              text: userDetailsResp["userDetails"]["houseNoStreetName"]);
          _buyerHouselocalityController = TextEditingController(
              text: userDetailsResp["userDetails"]["locality"]);
          _buyerHouseCityController = TextEditingController(
              text: userDetailsResp["userDetails"]["city"]);
          _buyerHouseStateController = TextEditingController(
              text: userDetailsResp["userDetails"]["state"]);
          _buyerHousePincodeController = TextEditingController(
              text: userDetailsResp["userDetails"]["pincode"].toString());
          _buyerEmailAddressController = TextEditingController(
              text: userDetailsResp["userDetails"]["email"]);
          _buyerPasswordController = TextEditingController(
              text: userDetailsResp["userDetails"]["userName"]);
          _buyerUserTypeController = TextEditingController(
              text: userDetailsResp["userDetails"]["userType"]);
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      isImageDataChanged = true;
      anyDataChanged = true;
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to pick Image: $e");
    }
  }

  Future<String> uploadImage(imageFile) async {
    const url =
        'https://api.imgbb.com/1/upload?key=e045e2fffae70141ef3857d1f362d1e1';

    final mimeType = mime(imageFile.path);
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path,
        contentType: MediaType.parse(mimeType!)));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final uploadedData = jsonDecode(responseData);
      // debugPrint(uploadedData['data']['url']);
      return uploadedData['data']['url'];
    } else {
      throw Exception('Failed to upload image to ImageBB');
    }
  }

  void updateUserInformation() async {
    Navigator.of(context).push(PageRouteBuilder(
        barrierColor: const Color.fromARGB(91, 158, 158, 158),
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const LoadingScreen();
        }));
    Map updatedData;
    String imageUploadedUrl = '';
    debugPrint("updateUserInformation");
    if (isImageDataChanged) {
      imageUploadedUrl = await uploadImage(image);
      debugPrint("imageUploadedUrl : $imageUploadedUrl");
      updatedData = {
        "avatarUrl": imageUploadedUrl,
        "userId": loggedInUserDetails.userId,
        "userName": _buyerNameController.text,
        "mobile": loggedInUserDetails.mobile,
        "houseNoStreetName": _buyerHouseNoStreetNameController.text,
        "locality": _buyerHouselocalityController.text,
        "city": _buyerHouseCityController.text,
        "state": _buyerHouseStateController.text,
        "pincode": int.parse(_buyerHousePincodeController.text)
      };
    } else {
      updatedData = {
        "userId": loggedInUserDetails.userId,
        "userName": _buyerNameController.text,
        "mobile": loggedInUserDetails.mobile,
        "houseNoStreetName": _buyerHouseNoStreetNameController.text,
        "locality": _buyerHouselocalityController.text,
        "city": _buyerHouseCityController.text,
        "state": _buyerHouseStateController.text,
        "pincode": int.parse(_buyerHousePincodeController.text)
      };
    }
    var updatedDataSent = json.encode(updatedData);
    http
        .put(
      updateUserDetailsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
      body: updatedDataSent,
    )
        .then((response) {
      var updateUserDetailsResp = json.decode(response.body);
      Navigator.of(context).pop();
      if (updateUserDetailsResp['Message'] == 'User updated') {
        if (isImageDataChanged) {
          setState(() {
            avatarUrl = imageUploadedUrl;
          });
        }
        // loggedInUserDetails.userId = loggedInUserDetails.userId;
        // loggedInUserDetails.userName = _buyerNameController.text;
        // loggedInUserDetails.houseNoStreetName =
        //     _buyerHouseNoStreetNameController.text;
        // loggedInUserDetails.locality = _buyerHouselocalityController.text;
        // loggedInUserDetails.city = _buyerHouseCityController.text;
        // loggedInUserDetails.state = _buyerHouseStateController.text;
        // loggedInUserDetails.pincode =
        //     int.parse(_buyerHousePincodeController.text);
        debugPrint("User details updated");
        isUserDataUpdated = true;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Details succesfully updated',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Couldn't change details",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              content: const Text("Try again later"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();

    isUserDataUpdated = false;

    updateUserDetailsUrl = Uri.http(authority, 'api/common/updateUserDetails');
    anyDataChanged = false;
    isImageDataChanged = false;

    _buyerNameController = TextEditingController(
        // text:
        // loggedInUserDetails.userName
        );
    _buyerPhoneController = TextEditingController(
        // text:
        // loggedInUserDetails.mobile
        );
    _buyerHouseNoStreetNameController = TextEditingController(
        // text:
        // loggedInUserDetails.houseNoStreetName
        );
    _buyerHouselocalityController = TextEditingController(
        // text:
        // loggedInUserDetails.locality
        );
    _buyerHouseCityController = TextEditingController(
        // text:
        // loggedInUserDetails.city
        );
    _buyerHouseStateController = TextEditingController(
        // text:
        // loggedInUserDetails.state
        );
    _buyerHousePincodeController = TextEditingController(
        // text:
        // loggedInUserDetails.pincode.toString()
        );
    _buyerEmailAddressController = TextEditingController(
        // text:
        // loggedInUserDetails.email
        );
    _buyerPasswordController = TextEditingController(
        // text:
        // loggedInUserDetails.mobile
        );
    _buyerUserTypeController = TextEditingController(
        // text:
        // loggedInUserDetails.userType
        );
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getUserDetails();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void dispose() {
    super.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _buyerHouseNoStreetNameController.dispose();
    _buyerHouselocalityController.dispose();
    _buyerHouseCityController.dispose();
    _buyerHouseStateController.dispose();
    _buyerHousePincodeController.dispose();
    _buyerEmailAddressController.dispose();
    _buyerPasswordController.dispose();
    _buyerUserTypeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile and Contact Settings",
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75),
                            ),
                            onTap: () {
                              pickImage();
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      75,
                                    ),
                                    color: const Color.fromARGB(
                                        136, 158, 158, 158),
                                    border: const Border(
                                      top: BorderSide(color: Colors.black),
                                      left: BorderSide(color: Colors.black),
                                      right: BorderSide(color: Colors.black),
                                      bottom: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: avatarUrl == '' && image == null
                                      ? const Center(
                                          child: Text("Profile Image"),
                                        )
                                      : image == null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(75),
                                              child: Image.network(
                                                avatarUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(75),
                                              child: Image.file(
                                                image!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 5.0,
                                    top: 15,
                                  ),
                                  child: isVerifiedProfile
                                      ? Tooltip(
                                          message: "Pofile verified",
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                              Container(
                                                height: 13,
                                                width: 13,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.verified,
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Tooltip(
                                          message: "Profile not yet verified.",
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                              Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.question_mark_sharp,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 25,
                            ),
                            child: TextFormField(
                              controller: _buyerNameController,
                              onChanged: (value) {
                                anyDataChanged = true;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: TextFormField(
                              readOnly: true,
                              controller: _buyerPhoneController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Phone Number',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: TextFormField(
                              controller: _buyerHouseNoStreetNameController,
                              onChanged: (value) {
                                anyDataChanged = true;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'House No.',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid house no.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 175,
                                  child: TextFormField(
                                    controller: _buyerHouselocalityController,
                                    onChanged: (value) {
                                      anyDataChanged = true;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'Locality',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid locality';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 175,
                                  child: TextFormField(
                                    controller: _buyerHouseStateController,
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
                                          'Authorization':
                                              loggedInUserAuthToken,
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
                                                        _buyerHouseStateController
                                                                .text =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.label =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.name =
                                                            statesList[index]
                                                                .name;
                                                        _buyerHouseCityController
                                                            .text = '';
                                                        anyDataChanged = true;
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
                                    // onChanged: (value) {
                                    //   anyDataChanged = true;
                                    // },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'State',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid state';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 175,
                                  child: TextFormField(
                                    controller: _buyerHouseCityController,
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
                                          'Authorization':
                                              loggedInUserAuthToken,
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
                                                        _buyerHouseCityController
                                                                .text =
                                                            cityList[index]
                                                                .label;
                                                        selectedCity.label =
                                                            cityList[index]
                                                                .label;
                                                        selectedCity.value =
                                                            cityList[index]
                                                                .value;
                                                        anyDataChanged = true;
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
                                    // onChanged: (value) {
                                    //   anyDataChanged = true;
                                    // },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'City',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid city name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 175,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _buyerHousePincodeController,
                                    onChanged: (value) {
                                      anyDataChanged = true;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      labelText: 'Pincode',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid Pincode';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: TextFormField(
                              readOnly: true,
                              controller: _buyerEmailAddressController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'Email Address',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: TextFormField(
                              readOnly: true,
                              controller: _buyerUserTypeController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'User type',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid type';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const BuyerPasswordResetScreen();
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.password_outlined,
                                  ),
                                  label: const Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 25,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (anyDataChanged == true) {
                                      if (isUserDataUpdated == false) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Discard Changes?',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              content: const Text(
                                                "Some details changed but are not saved. Discard them?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    anyDataChanged = false;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Discard',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: Color.fromARGB(255, 252, 96, 85),
                                  ),
                                  label: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 252, 96, 85),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    if (anyDataChanged) {
                                      updateUserInformation();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    "Update",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
