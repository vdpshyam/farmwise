import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';
import '../providers/user_reviews_provider.dart';
import '../screens/user_public_profile_screen.dart';

class SellerPostedByYouReviewWidget extends StatefulWidget {
  const SellerPostedByYouReviewWidget({
    super.key,
    required this.userReview,
    required this.updatePostedByYouReviewListFunc,
  });

  final PostedUserReview userReview;
  final Function updatePostedByYouReviewListFunc;

  @override
  State<SellerPostedByYouReviewWidget> createState() =>
      _SellerPostedByYouReviewWidgetState();
}

class _SellerPostedByYouReviewWidgetState
    extends State<SellerPostedByYouReviewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "You said:",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              left: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              right: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.userReview.review,
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
              "on ${widget.userReview.postedOn?.toLocal().day}/${widget.userReview.postedOn?.toLocal().month}/${widget.userReview.postedOn?.toLocal().year}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return UserPublicProfileScreen(
                        userId: widget.userReview.postedForId,
                      );
                    },
                  ),
                );
              },
              child: Text(
                widget.userReview.postedForName,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 27, 152, 255),
                ),
              ),
            ),
            const Text(
              "'s reply: ",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              top: BorderSide(color: Colors.grey, width: 0.5),
              left: BorderSide(color: Colors.grey, width: 0.5),
              right: BorderSide(color: Colors.grey, width: 0.5),
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.userReview.reply,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                var userReviewReplyUrl = Uri.http(
                  authority,
                  'api/common/deleteUserReview',
                );
                http
                    .delete(
                  userReviewReplyUrl,
                  headers: {'Authorization': loggedInUserAuthToken,
                    'Content-Type': 'application/json',
                  },
                  body: json.encode(
                    {
                      "id": widget.userReview.reviewId,
                    },
                  ),
                )
                    .then((value) {
                  var replyResp = json.decode(value.body);
                  if (replyResp["message"] == "User review deleted") {
                    widget.updatePostedByYouReviewListFunc(
                      widget.userReview.reviewId,
                    );
                    final snackBar = SnackBar(
                      content: Text(
                        'Successfully deleted review posted for ${widget.userReview.postedForName}',
                      ),
                      action: SnackBarAction(
                        label: 'Okay',
                        onPressed: () {},
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    final snackBar = SnackBar(
                      content: const Text(
                        'Could not delete.Try again later',
                      ),
                      action: SnackBarAction(
                        label: 'Okay',
                        onPressed: () {},
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                });
              },
              child: const Text(
                "Delete Review",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const Divider(
          height: 20,
          indent: 70,
          endIndent: 70,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
