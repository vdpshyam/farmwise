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
import 'seller_password_reset_screen.dart';

class SellerProfileSettingsScreen extends StatefulWidget {
  const SellerProfileSettingsScreen({super.key});

  // final String userName;
  // const SellerProfileSettingsScreen(this.userName);

  @override
  State<SellerProfileSettingsScreen> createState() =>
      _SellerProfileSettingsScreenState();
}

class StatesModel {
  String label, name;
  StatesModel({required this.label, required this.name});
}

class CityModel {
  String label, value;
  CityModel({required this.label, required this.value});
}

class _SellerProfileSettingsScreenState
    extends State<SellerProfileSettingsScreen> {
  // late Uri url;
  bool anyDataChanged = false,
      isImageDataChanged = false,
      isUserDataUpdated = false;
  late Uri updateUserDetailsUrl;
  bool isLoading = true;

  String avatarUrl = '';
  late TextEditingController _sellerNameController;
  late TextEditingController _sellerPhoneController;
  late TextEditingController _sellerHouseNoController;
  late TextEditingController _sellerHouseSteetNameController;
  late TextEditingController _sellerHouselocalityController;
  late TextEditingController _sellerHouseCityController;
  late TextEditingController _sellerHouseStateController;
  late TextEditingController _sellerHousePincodeController;
  late TextEditingController _sellerEmailAddressController;
  late TextEditingController _sellerPasswordController;
  late TextEditingController _sellerUserTypeController;
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
            avatarUrl = userDetailsResp["userDetails"]["avatarUrl"] ?? '';
            isVerifiedProfile =
                userDetailsResp["userDetails"]["verifiedProfile"] ? userDetailsResp["userDetails"]["verifiedProfile"] : false;
          });
          debugPrint("avatarUrl : $avatarUrl");
          _sellerNameController = TextEditingController(
              text: userDetailsResp["userDetails"]["userName"]);
          _sellerPhoneController = TextEditingController(
              text: userDetailsResp["userDetails"]["mobile"]);
          _sellerHouseSteetNameController = TextEditingController(
              text: userDetailsResp["userDetails"]["houseNoStreetName"]);
          _sellerHouselocalityController = TextEditingController(
              text: userDetailsResp["userDetails"]["locality"]);
          _sellerHouseCityController = TextEditingController(
              text: userDetailsResp["userDetails"]["city"]);
          _sellerHouseStateController = TextEditingController(
              text: userDetailsResp["userDetails"]["state"]);
          _sellerHousePincodeController = TextEditingController(
              text: userDetailsResp["userDetails"]["pincode"].toString());
          _sellerEmailAddressController = TextEditingController(
              text: userDetailsResp["userDetails"]["email"]);
          _sellerPasswordController = TextEditingController(
              text: userDetailsResp["userDetails"]["userName"]);
          _sellerUserTypeController = TextEditingController(
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
        "userName": _sellerNameController.text,
        "mobile": loggedInUserDetails.mobile,
        "houseNoStreetName": _sellerHouseSteetNameController.text,
        "locality": _sellerHouselocalityController.text,
        "city": _sellerHouseCityController.text,
        "state": _sellerHouseStateController.text,
        "pincode": int.parse(_sellerHousePincodeController.text)
      };
    } else {
      updatedData = {
        "userId": loggedInUserDetails.userId,
        "userName": _sellerNameController.text,
        "mobile": loggedInUserDetails.mobile,
        "houseNoStreetName": _sellerHouseSteetNameController.text,
        "locality": _sellerHouselocalityController.text,
        "city": _sellerHouseCityController.text,
        "state": _sellerHouseStateController.text,
        "pincode": int.parse(_sellerHousePincodeController.text)
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
          loggedInUserDetails.avatarUrl = imageUploadedUrl;
        }
        loggedInUserDetails.userId = loggedInUserDetails.userId;
        loggedInUserDetails.userName = _sellerNameController.text;
        loggedInUserDetails.houseNoStreetName =
            _sellerHouseSteetNameController.text;
        loggedInUserDetails.locality = _sellerHouselocalityController.text;
        loggedInUserDetails.city = _sellerHouseCityController.text;
        loggedInUserDetails.state = _sellerHouseStateController.text;
        loggedInUserDetails.pincode =
            int.parse(_sellerHousePincodeController.text);
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
  void initState() {
    super.initState();

    anyDataChanged = false;
    isUserDataUpdated = false;

    updateUserDetailsUrl = Uri.http(authority, 'api/common/updateUserDetails');

    _sellerNameController = TextEditingController(
        // text: loggedInUserDetails.userName
        );
    _sellerPhoneController = TextEditingController(
        // text: loggedInUserDetails.mobile
        );
    _sellerHouseNoController = TextEditingController(
        // text: loggedInUserDetails.houseNoStreetName
        );
    _sellerHouseSteetNameController = TextEditingController(
        // text: loggedInUserDetails.houseNoStreetName
        );
    _sellerHouselocalityController = TextEditingController(
        // text: loggedInUserDetails.locality
        );
    _sellerHouseCityController = TextEditingController(
        // text: loggedInUserDetails.city
        );
    _sellerHouseStateController = TextEditingController(
        // text: loggedInUserDetails.state
        );
    _sellerHousePincodeController = TextEditingController(
        // text: loggedInUserDetails.pincode.toString()
        );
    _sellerEmailAddressController = TextEditingController(
        // text: loggedInUserDetails.email
        );
    _sellerPasswordController = TextEditingController(
        // text: loggedInUserDetails.mobile
        );
    _sellerUserTypeController = TextEditingController(
        // text: loggedInUserDetails.userType
        );
    getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _sellerHouseNoController.dispose();
    _sellerHouseSteetNameController.dispose();
    _sellerHouselocalityController.dispose();
    _sellerHouseCityController.dispose();
    _sellerHouseStateController.dispose();
    _sellerHousePincodeController.dispose();
    _sellerEmailAddressController.dispose();
    _sellerPasswordController.dispose();
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
                              anyDataChanged = true;
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
                              controller: _sellerNameController,
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
                              controller: _sellerPhoneController,
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
                              controller: _sellerHouseSteetNameController,
                              onChanged: (value) {
                                anyDataChanged = true;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelText: 'House No. / Street name',
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
                                    controller: _sellerHouselocalityController,
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
                                    controller: _sellerHouseStateController,
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
                                                        _sellerHouseStateController
                                                                .text =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.label =
                                                            statesList[index]
                                                                .label;
                                                        selectedState.name =
                                                            statesList[index]
                                                                .name;
                                                        _sellerHouseCityController
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
                                )
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
                                    controller: _sellerHouseCityController,
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
                                                        _sellerHouseCityController
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
                                    controller: _sellerHousePincodeController,
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
                              controller: _sellerEmailAddressController,
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
                              controller: _sellerUserTypeController,
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
                                          return const SellerPasswordResetScreen();
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
