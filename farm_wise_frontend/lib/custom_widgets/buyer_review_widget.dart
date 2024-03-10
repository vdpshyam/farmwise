import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/user_reviews.dart';
import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/user_public_profile_screen.dart';

class BuyerReviewWidget extends StatefulWidget {
  const BuyerReviewWidget({
    super.key,
    required this.userReview,
  });
  final UserReview userReview;
  @override
  State<BuyerReviewWidget> createState() => _BuyerReviewWidgetState();
}

class _BuyerReviewWidgetState extends State<BuyerReviewWidget> {
  late TextEditingController _buyerReplyController;

  @override
  void initState() {
    super.initState();
    _buyerReplyController = TextEditingController(
      text: widget.userReview.reply,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _buyerReplyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return UserPublicProfileScreen(
                        userId: widget.userReview.postedById,
                      );
                    },
                  ),
                );
              },
              child: Text(
                widget.userReview.postedByName,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 27, 152, 255),
                ),
              ),
            ),
            const Text(
              " says: ",
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
              top: BorderSide(width: 0.75, color: Colors.black),
              left: BorderSide(width: 0.75, color: Colors.black),
              right: BorderSide(width: 0.75, color: Colors.black),
              bottom: BorderSide(width: 0.75, color: Colors.black),
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
          height: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              " on ${widget.userReview.postedOn?.toLocal().day}/${widget.userReview.postedOn?.toLocal().month}/${widget.userReview.postedOn?.toLocal().year}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),

        const SizedBox(
          height: 20,
        ),
        const Text(
          "Your reply:",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: _buyerReplyController,
          maxLines: 4,
          minLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            labelText: '',
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                var userReviewReplyUrl = Uri.http(
                  authority,
                  'api/common/replyToUserReview',
                );
                http
                    .put(
                  userReviewReplyUrl,
                  headers: {
                    'Authorization': loggedInUserAuthToken,
                    'Content-Type': 'application/json',
                  },
                  body: json.encode(
                    {
                      "id": widget.userReview.reviewId,
                      "reply": _buyerReplyController.text
                    },
                  ),
                )
                    .then((value) {
                  var replyResp = json.decode(value.body);
                  if (replyResp["message"] == "Reply set") {
                    final snackBar = SnackBar(
                      content: Text(
                        'Successfully replied to ${widget.userReview.postedByName}',
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
                        'Could not reply.Try again later',
                      ),
                      action: SnackBarAction(
                        label: 'Okay',
                        onPressed: () {},
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                });
                // var userReviewDeleteUrl = Uri.http(
                //   authority,
                //   'api/common/deleteUserReview',
                // );
                // http
                //     .delete(
                //   userReviewDeleteUrl,
                //   headers: {
                //     'Content-Type': 'application/json',
                //   },
                //   body: json.encode(
                //     {
                //       "id": widget.userReview.reviewId,
                //     },
                //   ),
                // )
                //     .then((value) {
                //   var replyResp = json.decode(value.body);
                //   if(replyResp["message"] == "User review deleted"){
                //     final snackBar = SnackBar(
                //     content: const Text(
                //       'Review deleted successfully',
                //     ),
                //     action: SnackBarAction(
                //       label: 'Okay',
                //       onPressed: () {},
                //     ),
                //   );
                //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                //   } else{
                //     final snackBar = SnackBar(
                //     content: const Text(
                //       'Could not delete review.Try again later',
                //     ),
                //     action: SnackBarAction(
                //       label: 'Okay',
                //       onPressed: () {},
                //     ),
                //   );
                //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                //   }
                // }
                // );
              },
              child: const Text(
                "Submit reply",
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
        //
      ],
    );
  }
}
