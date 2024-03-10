const mongoose = require("mongoose");

const ProductNewSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    productName: {
      type: String,
      required: true,
    },
    basePrice: {
      type: Number,
      required: true,
    },
    quantityPerLot: {
      type: Number,
      required: true,
    },
    quantityUnit: {
      type: String,
      required: true,
    },
    minNoLot: {
      type: Number,
      required: true,
    },
    productDesc: {
      type: String,
      required: true,
    },
    productImages: {
      type: Array,
      required: true,
    },
    producedDate: {
      type: Date,
      required: true,
    },
    availableFrom: {
      type: Date,
      required: true,
    },
    reviews: {
      type: Array,
    },
    ratings: {
      type: Number,
    },
    ratedUser: {
      type: Array,
    },
    location: {
      type: String,
      required: true,
    },
    availStatus: {
      type: Boolean,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const Product = mongoose.model("t_products", ProductNewSchema);

module.exports = Product;
