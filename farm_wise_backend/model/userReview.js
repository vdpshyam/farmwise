const mongoose = require("mongoose");

const UserReviewSchema = new mongoose.Schema(
  {
    postedBy: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    postedFor: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    review: {
      type: String,
      required: true,
    },
    reply: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

const UserReview = mongoose.model("t_user_reviews", UserReviewSchema);

module.exports = UserReview;
