import '../models/user_reviews.dart';

class PostedUserReview {
  String reviewId, postedForId, postedForName, review, reply;
  DateTime? postedOn;

  PostedUserReview({
    required this.reviewId,
    required this.postedForId,
    required this.postedForName,
    required this.review,
    required this.reply,
    required this.postedOn,
  });
}


var userReviews = <UserReview>[];
var postedUserReviews = <PostedUserReview>[];