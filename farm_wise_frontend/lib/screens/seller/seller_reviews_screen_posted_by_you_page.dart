import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../custom_widgets/seller_posted_by_you_review_widget.dart';
// import '../../custom_widgets/seller_review_widget.dart';
// import '../../models/user_reviews.dart';
import '../../providers/https_provider.dart';
import '../../providers/user_details_provider.dart';
import '../../providers/user_reviews_provider.dart';

class SellerReviewsScreenPostedByYouPage extends StatefulWidget {
  const SellerReviewsScreenPostedByYouPage({super.key});

  @override
  State<SellerReviewsScreenPostedByYouPage> createState() =>
      _SellerReviewsScreenPostedByYouPageState();
}

class _SellerReviewsScreenPostedByYouPageState
    extends State<SellerReviewsScreenPostedByYouPage> {
  bool isLoading = true;
  late Uri postedByYouUserReviewUrl;

  void getPostedByYouUserReviews() async {
    var getUserReviewsResponse = await http.get(postedByYouUserReviewUrl,headers: {
      'Authorization': loggedInUserAuthToken,
      'Content-Type': 'application/json'
    });
    var userReviewsResponse = json.decode(getUserReviewsResponse.body);
    postedUserReviews.clear();
    if (userReviewsResponse["message"] == "User reviews recieved") {
      for (int i = 0; i < userReviewsResponse["userReviews"].length; i++) {
        postedUserReviews.add(
          PostedUserReview(
            reviewId: userReviewsResponse["userReviews"][i]['_id'],
            postedForName: userReviewsResponse["userReviews"][i]
                ['postedForDetails'][0]['userName'],
            postedForId: userReviewsResponse["userReviews"][i]
                ['postedForDetails'][0]['_id'],
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

  void updatePostedByYouReviewList(reviewId){
    setState(() {
      postedUserReviews.removeWhere((element) => element.reviewId == reviewId);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    getPostedByYouUserReviews();
    setState(() {
      isLoading = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    postedByYouUserReviewUrl = Uri.https(
      authority,
      'api/common/getPostedUserReview',
      {
        "postedBy": loggedInUserDetails.userId,
      },
    );
    getPostedByYouUserReviews();
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
            child: postedUserReviews.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 160,),
                        SizedBox(
                          height: 200,
                          child: Image.asset(
                              "lib/assets/images/reviewpostedbyyou1.png"),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: Text(
                            "No reviews yet. When you post a review for a user, it can be seen from here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: postedUserReviews.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          // vertical: 10.0,
                          horizontal: 25,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            SellerPostedByYouReviewWidget(
                              userReview: postedUserReviews[index],
                              updatePostedByYouReviewListFunc: updatePostedByYouReviewList
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
