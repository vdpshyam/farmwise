const mongoose = require("mongoose");

const SubscriptionDetailsNewSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    creditAmount: {
      type: Number,
      required: true,
    },
    transactionsLeft: {
      type: Number,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const SubscriptionDetail = mongoose.model(
  "t_subscription_details",
  SubscriptionDetailsNewSchema
);

module.exports = SubscriptionDetail;
