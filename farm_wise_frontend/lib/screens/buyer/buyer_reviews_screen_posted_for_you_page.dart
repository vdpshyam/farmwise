import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../custom_widgets/buyer_review_widget.dart';
import '../../models/user_reviews.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../../providers/user_reviews_provider.dart';

class BuyerReviewsScreenPostedForYouPage extends StatefulWidget {
  const BuyerReviewsScreenPostedForYouPage({super.key});

  @override
  State<BuyerReviewsScreenPostedForYouPage> createState() =>
      _BuyerReviewsScreenPostedForYouPageState();
}

class _BuyerReviewsScreenPostedForYouPageState
    extends State<BuyerReviewsScreenPostedForYouPage> {
  late Uri userReviewUrl;
  bool isLoading = true;

  void getPostedForYouUserReviews() async {
    var getUserReviewsResponse = await http.get(userReviewUrl,headers: {
      'Authorization': loggedInUserAuthToken,
      'Content-Type': 'application/json'
    });
    var userReviewsResponse = json.decode(getUserReviewsResponse.body);
    userReviews.clear();
    if (userReviewsResponse["message"] == "User reviews recieved") {
      for (int i = 0; i < userReviewsResponse["userReviews"].length; i++) {
        userReviews.add(
          UserReview(
            reviewId: userReviewsResponse["userReviews"][i]['_id'],
            postedByName: userReviewsResponse["userReviews"][i]
                ['postedByDetails'][0]['userName'],
            postedById: userReviewsResponse["userReviews"][i]['postedByDetails']
                [0]['_id'],
            review: userReviewsResponse["userReviews"][i]['review'],
            reply: userReviewsResponse["userReviews"][i]['reply'],
            postedOn: DateTime.parse(
              userReviewsResponse["userReviews"][i]['createdAt'],
            ),
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getPostedForYouUserReviews();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    userReviewUrl = Uri.https(
      authority,
      'api/common/getUserReview',
      {
        "postedFor": loggedInUserDetails.userId,
      },
    );
    getPostedForYouUserReviews();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 37, 143, 83),
            ),
          )
        : RefreshIndicator(
            onRefresh: _onRefresh,
            child: userReviews.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 160,),
                        SizedBox(
                          height: 190,
                          child: Image.asset(
                              "lib/assets/images/reviewpostedforyou1.png"),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0,vertical: 10),
                          child: Text(
                            "No reviews yet. When a user post a review for you, it can be seen from here. You can also reply to the review from here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: userReviews.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            BuyerReviewWidget(
                              userReview: userReviews[index],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
