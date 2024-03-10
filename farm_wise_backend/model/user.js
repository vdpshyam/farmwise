const mongoose = require("mongoose");

const UserNewSchema = new mongoose.Schema(
  {
    userName: {
      type: String,
      required: true,
    },
    avatarUrl: {
      type: String,
    },
    mobile: {
      type: String,
      required: true,
    },
    userType: {
      type: String,
      required: true,
    },
    email: {
      type: String,
    },
    houseNoStreetName: {
      type: String,
      required: true,
    },
    locality: {
      type: String,
      required: true,
    },
    city: {
      type: String,
      required: true,
    },
    state: {
      type: String,
      required: true,
    },
    pincode: {
      type: Number,
      required: true,
    },
    verifiedProfile: {
      type: Boolean,
      required: true,
    },
    verifyMobile: {
      type: Boolean,
    },
    password: {
      type: String,
      required: true,
    },
    ratings: {
      type: Number,
    },
    ratedUser: {
      type: Array,
    },
    favoriteProducts: {
      type: Array,
    },
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("t_users", UserNewSchema);

module.exports = User;
