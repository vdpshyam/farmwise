// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:farm_wise_frontend/providers/user_details_provider.dart';
// import 'package:farm_wise_frontend/providers/user_reviews_provider.dart';

// import '../../custom_widgets/seller_posted_by_you_review_widget.dart';
// import '../../custom_widgets/seller_review_widget.dart';
// import '../../models/user_reviews.dart';
// import '../../providers/https_provider.dart';
import 'seller_reviews_screen_posted_by_you_page.dart';
import 'seller_reviews_screen_posted_for_you_page.dart';

class SellerReviewsScreen extends StatefulWidget {
  const SellerReviewsScreen({super.key});

  @override
  State<SellerReviewsScreen> createState() => _SellerReviewsScreenState();
}

class _SellerReviewsScreenState extends State<SellerReviewsScreen> {
  // late Uri userReviewUrl, postedUserReviewUrl;
  // bool isLoading = true;

  // void getUserReviews() async {
  //   var getUserReviewsResponse = await http.get(userReviewUrl);
  //   var userReviewsResponse = json.decode(getUserReviewsResponse.body);
  //   userReviews.clear();
  //   if (userReviewsResponse["message"] == "User reviews recieved") {
  //     for (int i = 0; i < userReviewsResponse["userReviews"].length; i++) {
  //       userReviews.add(
  //         UserReview(
  //           reviewId: userReviewsResponse["userReviews"][i]['_id'],
  //           postedByName: userReviewsResponse["userReviews"][i]
  //               ['postedByDetails'][0]['userName'],
  //           postedById: userReviewsResponse["userReviews"][i]['postedByDetails']
  //               [0]['_id'],
  //           review: userReviewsResponse["userReviews"][i]['review'],
  //           reply: userReviewsResponse["userReviews"][i]['reply'],
  //           postedOn: DateTime.parse(
  //             userReviewsResponse["userReviews"][i]['createdAt'],
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // void getPostedUserReviews() async {
  //   var getUserReviewsResponse = await http.get(postedUserReviewUrl);
  //   var userReviewsResponse = json.decode(getUserReviewsResponse.body);
  //   postedUserReviews.clear();
  //   if (userReviewsResponse["message"] == "User reviews recieved") {
  //     for (int i = 0; i < userReviewsResponse["userReviews"].length; i++) {
  //       postedUserReviews.add(
  //         PostedUserReview(
  //           reviewId: userReviewsResponse["userReviews"][i]['_id'],
  //           postedForName: userReviewsResponse["userReviews"][i]
  //               ['postedForDetails'][0]['userName'],
  //           postedForId: userReviewsResponse["userReviews"][i]
  //               ['postedForDetails'][0]['_id'],
  //           review: userReviewsResponse["userReviews"][i]['review'],
  //           reply: userReviewsResponse["userReviews"][i]['reply'],
  //           postedOn: DateTime.parse(
  //             userReviewsResponse["userReviews"][i]['createdAt'],
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // userReviewUrl = Uri.http(
    //   authority,
    //   'api/common/getUserReview',
    //   {
    //     "postedFor": loggedInUserDetails.userId,
    //   },
    // );
    // postedUserReviewUrl = Uri.http(
    //   authority,
    //   'api/common/getPostedUserReview',
    //   {
    //     "postedBy": loggedInUserDetails.userId,
    //   },
    // );
    // getUserReviews();
    // getPostedUserReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reviews and Comments",
        ),
      ),
      body: const DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  text: "Posted for you",
                ),
                Tab(
                  text: "posted by you",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SellerReviewScreenPostedForYouPage(),
                  // userReviews.isEmpty
                  //     ? const Center(
                  //         child: Padding(
                  //           padding:
                  //               EdgeInsets.symmetric(horizontal: 50.0),
                  //           child: Text(
                  //             "No reviews yet. When a user post a review for you, it can be seen from here. You can also reply to the review from here.",
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(fontSize: 16),
                  //           ),
                  //         ),
                  //       )
                  //     : Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 30.0,
                  //           horizontal: 25,
                  //         ),
                  //         child: ListView.builder(
                  //           itemCount: userReviews.length,
                  //           itemBuilder: (context, index) {
                  //             return SellerReviewWidget(
                  //               userReview: userReviews[index],
                  //             );
                  //           },
                  //         ),
                  //       ),
                  SellerReviewsScreenPostedByYouPage(),
                  // postedUserReviews.isEmpty
                  //     ? const Center(
                  //         child: Padding(
                  //           padding:
                  //               EdgeInsets.symmetric(horizontal: 50.0),
                  //           child: Text(
                  //             "No reviews yet. When you post a review for a user, it can be seen from here.",
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(fontSize: 16),
                  //           ),
                  //         ),
                  //       )
                  //     : ListView.builder(
                  //         itemCount: postedUserReviews.length,
                  //         itemBuilder: (context, index) {
                  //           return Padding(
                  //             padding: const EdgeInsets.symmetric(
                  //               // vertical: 10.0,
                  //               horizontal: 25,
                  //             ),
                  //             child: Column(
                  //               children: [
                  //                 const SizedBox(height: 30,),
                  //                 SellerPostedByYouReviewWidget(
                  //                   userReview: postedUserReviews[index],
                  //                 ),
                  //               ],
                  //             ),
                  //           );
                  //         },
                  //       ),
                ],
              ),
            ),
          ],
        ),

        // userReviews.isEmpty
        //         ? const Center(
        //             child: Padding(
        //               padding: EdgeInsets.symmetric(horizontal: 50.0),
        //               child: Text(
        //                 "No reviews yet. When a user post a review for you, it can be seen from here. You can also reply to the review from here.",
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(fontSize: 16),
        //               ),
        //             ),
        //           )
        //         : Padding(
        //             padding: const EdgeInsets.symmetric(
        //               vertical: 30.0,
        //               horizontal: 25,
        //             ),
        //             child: ListView.builder(
        //               itemCount: userReviews.length,
        //               itemBuilder: (context, index) {
        //                 return SellerReviewWidget(
        //                   userReview: userReviews[index],
        //                 );
        //               },
        //             ),
        //           ),
      ),
    );
  }
}
