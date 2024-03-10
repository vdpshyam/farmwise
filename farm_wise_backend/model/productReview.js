const mongoose = require("mongoose");

const ProductReviewSchema = new mongoose.Schema(
  {
    sellerId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    buyerId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    productId: {
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

const ProductReview = mongoose.model("t_product_reviews", ProductReviewSchema);

module.exports = ProductReview;

