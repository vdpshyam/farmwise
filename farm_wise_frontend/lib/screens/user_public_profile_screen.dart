import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:farm_wise_frontend/providers/user_details_provider.dart';

import '../providers/https_provider.dart';
import 'buyer/buyer_item_detail_screen.dart';
import 'buyer/buyer_view_seller_all_listed_products_screen.dart';
import 'buyer/buyer_view_seller_all_reviews.dart';

class UserPublicProfileScreen extends StatefulWidget {
  const UserPublicProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserPublicProfileScreen> createState() =>
      _UserPublicProfileScreenState();
}

class SellerListedProductsListTile {
  String productId, productName, quantityUnit;
  int basePrice;
  List productImages;

  SellerListedProductsListTile({
    required this.productId,
    required this.productName,
    required this.quantityUnit,
    required this.basePrice,
    required this.productImages,
  });
}

class UserReviewsListTile {
  String reviewId,
      review,
      reply,
      postedByName,
      postedByUserId,
      postedForName,
      postedForUserId;
  DateTime postedOn;

  UserReviewsListTile({
    required this.reviewId,
    required this.review,
    required this.reply,
    required this.postedByName,
    required this.postedByUserId,
    required this.postedForName,
    required this.postedForUserId,
    required this.postedOn,
  });
}

class _UserPublicProfileScreenState extends State<UserPublicProfileScreen> {
  bool isLoading = true, isUserDealClosedCheckLoading = false;
  late Uri getUserDetailsUrl;
  late TextEditingController _loggedInUserGiveReviewController;

  // userDetails variables
  late String userId, userName, mobile, avatarUrl, userType, email, city, state;
  late int ratings;
  late bool isVerifiedProfile, verifyMobile;
  late List ratedUser;

  //listedProducts variables
  List<SellerListedProductsListTile> productsBylimitList = [];

  //userReviews variables
  List<UserReviewsListTile> userReviewsBylimitList = [];

  void getUserDetails() async {
    await http.get(
      getUserDetailsUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      var getUserDetailsResp = json.decode(response.body);
      if (response.statusCode == 200) {
        if (getUserDetailsResp["message"] == "User found") {
          // print(getUserDetailsResp['userDetails']);
          userId = getUserDetailsResp['userDetails']['_id'];
          userName = getUserDetailsResp['userDetails']['userName'];
          avatarUrl = getUserDetailsResp['userDetails']['avatarUrl'];
          mobile = getUserDetailsResp['userDetails']['mobile'];
          userType = getUserDetailsResp['userDetails']['userType'];
          email = getUserDetailsResp['userDetails']['email'];
          city = getUserDetailsResp['userDetails']['city'];
          state = getUserDetailsResp['userDetails']['state'];
          ratings = getUserDetailsResp['userDetails']['ratings'];
          isVerifiedProfile =
              getUserDetailsResp['userDetails']['verifiedProfile'];
          verifyMobile = getUserDetailsResp['userDetails']['verifyMobile'];
          ratedUser = getUserDetailsResp['userDetails']['ratedUser'];
        } else {
          final snackBar = SnackBar(
            content: const Text(
              'User not found',
            ),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        final snackBar = SnackBar(
          content: const Text(
            'Something went wrong.Please try again later.',
          ),
          action: SnackBarAction(
            label: 'okay',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    //For getting listed products
    if (userType == "Farmer") {
      var getSellerListedProductsLimitUrl = Uri.http(
        authority,
        "api/farmer/getProductsLimit",
        {
          "userId": userId,
          "noOfProd": "3",
        },
      );
      await http.get(
        getSellerListedProductsLimitUrl,
        headers: {
          'Authorization': loggedInUserAuthToken,
          'Content-Type': 'application/json'
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var getProductsLimitResp = json.decode(response.body);
          if (getProductsLimitResp["message"] == "Products by limit found") {
            // print(getProductsLimitResp['productsByLimit']);
            for (int i = 0;
                i < getProductsLimitResp['productsByLimit'].length;
                i++) {
              productsBylimitList.add(
                SellerListedProductsListTile(
                  productId: getProductsLimitResp['productsByLimit'][i]["_id"],
                  productName: getProductsLimitResp['productsByLimit'][i]
                      ["productName"],
                  quantityUnit: getProductsLimitResp['productsByLimit'][i]
                      ["quantityUnit"],
                  basePrice: getProductsLimitResp['productsByLimit'][i]
                      ["basePrice"],
                  productImages: getProductsLimitResp['productsByLimit'][i]
                      ["productImages"],
                ),
              );
            }
          }
        } else {
          final snackBar = SnackBar(
            content: const Text(
              'Something went wrong.Please try again later.',
            ),
            action: SnackBarAction(
              label: 'okay',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }

    //For getting reviews
    var getUserReviewsByLimitUrl = Uri.http(
      authority,
      "api/common/getUserReviewByLimit",
      {
        "postedFor": widget.userId,
        "noOfReviews": "3",
      },
    );
    await http.get(
      getUserReviewsByLimitUrl,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var getUserReviewsByLimitResp = json.decode(response.body);
        if (getUserReviewsByLimitResp["message"] ==
            "User reviews by limit recieved") {
          // print(getUserReviewsByLimitResp['userReviews']);
          if (getUserReviewsByLimitResp['userReviews'].length > 0) {
            for (int i = 0;
                i < getUserReviewsByLimitResp['userReviews'].length;
                i++) {
              userReviewsBylimitList.add(
                UserReviewsListTile(
                  reviewId: getUserReviewsByLimitResp['userReviews'][i]["_id"],
                  review: getUserReviewsByLimitResp['userReviews'][i]["review"],
                  reply: getUserReviewsByLimitResp['userReviews'][i]["reply"],
                  postedOn: DateTime.parse(
                      getUserReviewsByLimitResp['userReviews'][i]["createdAt"]),
                  postedByUserId: getUserReviewsByLimitResp['userReviews'][i]
                      ["postedByDetails"][0]["_id"],
                  postedByName: getUserReviewsByLimitResp['userReviews'][i]
                      ["postedByDetails"][0]["userName"],
                  postedForUserId: getUserReviewsByLimitResp['userReviews'][i]
                      ["postedForDetails"][0]["_id"],
                  postedForName: getUserReviewsByLimitResp['userReviews'][i]
                      ["postedForDetails"][0]["userName"],
                ),
              );
            }
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        final snackBar = SnackBar(
          content: const Text(
            'Something went wrong.Could not fetch reviews. Try again later.',
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

  void loggedInUserLeaveReview() {
    setState(() {
      isUserDealClosedCheckLoading = true;
    });
    Uri checkIfUserDealClosed;
    if (loggedInUserDetails.userType == 'Wholesaler') {
      checkIfUserDealClosed = Uri.http(
          authority,
          'api/common/checkIfDealClosed',
          {'sellerId': userId, 'buyerId': loggedInUserDetails.userId});
    } else {
      checkIfUserDealClosed = Uri.http(
          authority,
          'api/common/checkIfDealClosed',
          {'buyerId': userId, 'sellerId': loggedInUserDetails.userId});
    }
    http.get(
      checkIfUserDealClosed,
      headers: {
        'Authorization': loggedInUserAuthToken,
        'Content-Type': 'application/json'
      },
    ).then(
      (response) {
        setState(() {
          isUserDealClosedCheckLoading = false;
        });

        if (response.statusCode == 200) {
          var checkIfUserDealClosedResp = json.decode(response.body);
          if (checkIfUserDealClosedResp["message"] == "User deal closed") {
            showModalBottomSheet<void>(
              isScrollControlled: true,
              context: context,
              shape: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: 275,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 20,
                            bottom: 15,
                          ),
                          child: Text(
                            "Type your review for $userName",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child: TextField(
                            controller: _loggedInUserGiveReviewController,
                            maxLines: 5,
                            minLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              labelText: 'Type review here',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text(
                                  'Submit review',
                                ),
                                onPressed: () {
                                  if (_loggedInUserGiveReviewController.text !=
                                      '') {
                                    var postUserReviewUrl = Uri.http(
                                      authority,
                                      'api/common/postUserReview',
                                    );
                                    http
                                        .post(postUserReviewUrl,
                                            headers: {
                                              'Authorization':
                                                  loggedInUserAuthToken,
                                              'Content-Type': 'application/json'
                                            },
                                            body: json.encode({
                                              "postedBy":
                                                  loggedInUserDetails.userId,
                                              "postedFor": userId,
                                              "review":
                                                  _loggedInUserGiveReviewController
                                                      .text,
                                              "reply": ""
                                            }))
                                        .then((response) {
                                      if (response.statusCode == 200) {
                                        var postUserReviewResp =
                                            json.decode(response.body);
                                        if (postUserReviewResp["message"] ==
                                            "Review posted") {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              elevation: 15,
                                              action: SnackBarAction(
                                                label: 'okay',
                                                onPressed: () {},
                                              ),
                                              content: Text(
                                                'Your review for $userName was successfully posted.',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              duration: const Duration(
                                                milliseconds: 5000,
                                              ),
                                              width: 380.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 15,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                              ),
                                            ),
                                          );
                                        } else if (postUserReviewResp[
                                                "message"] ==
                                            "Unable to post review") {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              elevation: 15,
                                              action: SnackBarAction(
                                                label: 'okay',
                                                onPressed: () {},
                                              ),
                                              content: const Text(
                                                'Unable to post review.Try again later',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              duration: const Duration(
                                                milliseconds: 5000,
                                              ),
                                              width: 380.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 15,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                              ),
                                            ),
                                          );
                                        }
                                        _loggedInUserGiveReviewController.text =
                                            "";
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (checkIfUserDealClosedResp["message"] ==
              "User deal not closed") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 15,
                action: SnackBarAction(
                  label: 'okay',
                  onPressed: () {},
                ),
                content: const Text(
                  'Please close a deal to be eligible to leave a review',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                duration: const Duration(
                  milliseconds: 5000,
                ),
                width: 380.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Something went wrong! Try again later.',
              ),
              action: SnackBarAction(
                label: 'okay',
                onPressed: () {},
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserDetailsUrl = Uri.http(
      authority,
      'api/common/getUserDetails',
      {"id": widget.userId},
    );
    getUserDetails();
    _loggedInUserGiveReviewController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 37, 143, 83),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "$userName's profile",
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  75,
                                ),
                                color: const Color.fromARGB(136, 158, 158, 158),
                                border: const Border(
                                  top: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.black),
                                  right: BorderSide(color: Colors.black),
                                  bottom: BorderSide(color: Colors.black),
                                ),
                              ),
                              child: avatarUrl == ''
                                  ? const Center(
                                      child: Text("Profile Image"),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(75),
                                      child: Image.network(
                                        avatarUrl,
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
                                        alignment: AlignmentDirectional.center,
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
                                        alignment: AlignmentDirectional.center,
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
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 20.0),
                      child: Row(
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // Text(
                              //   "Mobile",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              // Text(
                              //   "Email",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              Text(
                                "User type",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "From",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Column(
                            children: [
                              Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // Text(
                              //   ":",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              // Text(
                              //   ":",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              // Text(
                              //   mobile,
                              //   style: const TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              // Text(
                              //   email,
                              //   style: const TextStyle(
                              //     fontSize: 18,
                              //   ),
                              // ),
                              Text(
                                userType,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "$city, $state",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (userType == 'Farmer')
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5,
                        ),
                        child: Text(
                          "Listed products : ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (userType == 'Farmer')
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: productsBylimitList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return BuyerItemDetailScreen(
                                          productId: productsBylimitList[index]
                                              .productId,
                                        );
                                      },
                                    ),
                                  );
                                },
                                leading: SizedBox(
                                  // height: 50,
                                  width: 85,
                                  child: Image.network(
                                    productsBylimitList[index].productImages[0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                    productsBylimitList[index].productName),
                                subtitle: Text(
                                  "Rs.${productsBylimitList[index].basePrice}/${productsBylimitList[index].quantityUnit}",
                                ),
                              ),
                              const Divider(
                                height: 0,
                                indent: 60,
                                endIndent: 60,
                              ),
                            ],
                          );
                        },
                      ),
                    if (userType == 'Farmer')
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BVSellerListedProductsScreen(
                                        userId: userId,
                                        userName: userName,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "See all listed products",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5,
                      ),
                      child: Text(
                        "What other users have to say?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.0,
                      ),
                      child: Text(
                        "Genuine reviews :  only buyers who closed a deal with this user are allowed to leave a review.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 142, 142, 142),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          isUserDealClosedCheckLoading
                              ? const Padding(
                                  padding: EdgeInsets.only(right: 62.0),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: () {
                                    loggedInUserLeaveReview();
                                  },
                                  icon: const Icon(Icons.reviews_outlined),
                                  label: const Text(
                                    "Leave a review",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: userReviewsBylimitList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 80,
                                ),
                                child: Text(
                                  "No user reviews posted for this user yet.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: userReviewsBylimitList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        Text(
                                          "${userReviewsBylimitList[index].postedByName} says",
                                          // "${widget.userReview.postedByName} says",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          width: double.maxFinite,
                                          // decoration: BoxDecoration(
                                          //   borderRadius: BorderRadius.circular(10),
                                          //   border: const Border(
                                          //     top: BorderSide(
                                          //       color: Color.fromARGB(
                                          //           114, 158, 158, 158),
                                          //       width: 0.5,
                                          //     ),
                                          //     left: BorderSide(
                                          //       color: Color.fromARGB(
                                          //           114, 158, 158, 158),
                                          //       width: 0.5,
                                          //     ),
                                          //     right: BorderSide(
                                          //       color: Color.fromARGB(
                                          //           114, 158, 158, 158),
                                          //       width: 0.5,
                                          //     ),
                                          //     bottom: BorderSide(
                                          //       color: Color.fromARGB(
                                          //           114, 158, 158, 158),
                                          //       width: 0.5,
                                          //     ),
                                          //   ),
                                          // ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              userReviewsBylimitList[index]
                                                  .review,
                                              // widget.userReview.review,
                                              overflow: TextOverflow.fade,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "on ${userReviewsBylimitList[index].postedOn.toLocal().day}/${userReviewsBylimitList[index].postedOn.toLocal().month}/${userReviewsBylimitList[index].postedOn.toLocal().year}",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        if (userReviewsBylimitList[index]
                                                .reply !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "$userName's reply: ",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  // decoration: BoxDecoration(
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(10),
                                                  //   border: const Border(
                                                  //     top: BorderSide(
                                                  //         color: Color.fromARGB(
                                                  //             114, 158, 158, 158),
                                                  //         width: 0.5),
                                                  //     left: BorderSide(
                                                  //         color: Color.fromARGB(
                                                  //             114, 158, 158, 158),
                                                  //         width: 0.5),
                                                  //     right: BorderSide(
                                                  //         color: Color.fromARGB(
                                                  //             114, 158, 158, 158),
                                                  //         width: 0.5),
                                                  //     bottom: BorderSide(
                                                  //         color: Color.fromARGB(
                                                  //             114, 158, 158, 158),
                                                  //         width: 0.5),
                                                  //   ),
                                                  // ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      userReviewsBylimitList[
                                                              index]
                                                          .reply,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 0,
                                      indent: 60,
                                      endIndent: 60,
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (userReviewsBylimitList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BVSellerAllReviewsScreen(
                                        userId: userId,
                                        userName: userName,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "See all user reviews",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }
}
