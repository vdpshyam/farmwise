import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:farm_wise_frontend/models/user_reviews.dart';

import '../providers/https_provider.dart';
import '../providers/user_details_provider.dart';
import '../screens/user_public_profile_screen.dart';

class SellerReviewWidget extends StatefulWidget {
  const SellerReviewWidget({
    super.key,
    required this.userReview,
  });

  final UserReview userReview;

  @override
  State<SellerReviewWidget> createState() => _SellerReviewWidgetState();
}

class _SellerReviewWidgetState extends State<SellerReviewWidget> {
  late TextEditingController _sellerReplyController;

  @override
  void initState() {
    super.initState();
    _sellerReplyController = TextEditingController(
      text: widget.userReview.reply,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _sellerReplyController.dispose();
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
              " says:",
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
        const Text(
          "Your reply: ",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: _sellerReplyController,
          maxLines: 4,
          minLines: 3,
          decoration: const InputDecoration(
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.all(Radius.circular(4)),
            //   borderSide: BorderSide(width: 1, color: Colors.red),
            // ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            labelText: '',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                var userReviewReplyUrl = Uri.https(
                  authority,
                  'api/farmer/replyToUserReview',
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
                      "reply": _sellerReplyController.text
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
              },
              child: const Text(
                "Submit Reply",
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
