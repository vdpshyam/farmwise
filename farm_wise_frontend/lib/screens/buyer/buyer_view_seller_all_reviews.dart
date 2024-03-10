import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';

class BVSellerAllReviewsScreen extends StatefulWidget {
  const BVSellerAllReviewsScreen(
      {super.key, required this.userId, required this.userName});

  final String userId, userName;

  @override
  State<BVSellerAllReviewsScreen> createState() =>
      _BVSellerAllReviewsScreenState();
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

class _BVSellerAllReviewsScreenState extends State<BVSellerAllReviewsScreen> {
  bool isLoading = true;
  late Uri getAllReviewsUrl;

  List<UserReviewsListTile> reviewsList = [];

  void getAllUserReviews() {
    http.get(
      getAllReviewsUrl,
      headers: {'Authorization': loggedInUserAuthToken,'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        var getUserReviewsByLimitResp = json.decode(response.body);
        if (getUserReviewsByLimitResp["message"] ==
            "User reviews by limit recieved") {
          // print(getUserReviewsByLimitResp['userReviews']);
          for (int i = 0;
              i < getUserReviewsByLimitResp['userReviews'].length;
              i++) {
            reviewsList.add(
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

  @override
  void initState() {
    super.initState();
    getAllReviewsUrl = Uri.https(
      authority,
      "api/common/getUserReviewByLimit",
      {
        "postedFor": widget.userId,
        "noOfReviews": "0",
      },
    );
    getAllUserReviews();
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
              title: Text("${widget.userName}'s reviews"),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
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
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: reviewsList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 25,
                                ),
                                Text(
                                  "${reviewsList[index].postedByName} says",
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
                                      reviewsList[index].review,
                                      // widget.userReview.review,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "on ${reviewsList[index].postedOn.toLocal().day}/${reviewsList[index].postedOn.toLocal().month}/${reviewsList[index].postedOn.toLocal().year}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (reviewsList[index].reply != '')
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${widget.userName}'s reply: ",
                                          style: const TextStyle(fontSize: 20),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              reviewsList[index].reply,
                                              overflow: TextOverflow.fade,
                                              style:
                                                  const TextStyle(fontSize: 16),
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
                  ],
                ),
              ),
            ),
          );
  }
}
