class UserReview {
  String reviewId, postedById, postedByName, review, reply;
  DateTime? postedOn;

  UserReview({
    required this.reviewId,
    required this.postedById,
    required this.postedByName,
    required this.review,
    required this.reply,
    required this.postedOn,
  });
}
