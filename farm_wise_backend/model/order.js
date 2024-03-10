const mongoose = require("mongoose");

const OrderSchema = new mongoose.Schema(
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
    basePrice: {
      type: Number,
      required: true,
    },
    dealPrice: {
      type: Number,
      required: true,
    },
    orderQtyLots: {
      type: Number,
      required: true,
    },
    orderValue: {
      type: Number,
      required: true,
    },
    isOrderAccepted: {
      type: Boolean,
      required: true,
    },
    paymentMode: {
      type: String,
      required: true,
    },
    halfPaymentDone: {
      type: Boolean,
      required: true,
    },
    fullPaymentDone: {
      type: Boolean,
      required: true,
    },
    isClosed: {
      type: Boolean,
    },
    isSellerClosed: {
      type: Boolean,
    },
    isBuyerClosed: {
      type: Boolean,
    },
    sellerClosedOn: {
      type: Date,
    },
    buyerClosedOn: {
      type: Date,
    },
    closedOn: {
      type: Date,
    },
    requiredOnOrBefore: {
      type: Date,
    },
    expectingResponseBefore: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

const Order = mongoose.model("t_orders", OrderSchema);

module.exports = Order;
