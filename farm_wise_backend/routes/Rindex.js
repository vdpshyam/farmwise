const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const saltRounds = 10;
const dotenv = require("dotenv");
const jwt = require("jsonwebtoken");
const verifyAuthToken = require("../middleware/verifyAuthToken");

const User = require("../model/user");
const Product = require("../model/product");
const Order = require("../model/order");
const ProductReview = require("../model/productReview");
const UserReview = require("../model/userReview");
const SubscriptionDetail = require("../model/subscriptionDetails");
const Indian_states_cities_list = require("indian-states-cities-list");
dotenv.config();

var moment = require("moment");

const router = require("express").Router({
  caseSensitive: true,
});

router.get("/commonalive", (req, res) => {
  // console.log("alive called");
  res.status(200).send({ status: "alive" });
});
//get state wise city list
router.get("/statewisecities", (req, res) => {
  // console.log("alive called");
  res.status(200).send({
    status: "alive",
    data: Indian_states_cities_list.STATE_WISE_CITIES,
  });
});
//get all states in india
router.get("/stateslist", (req, res) => {
  // console.log("alive called");
  res
    .status(200)
    .send({ status: "alive", data: Indian_states_cities_list.STATES_OBJECT });
});

//get city based on city
router.get("/citylistbystate", (req, res) => {
  // console.log("alive called");
  let states = req.query.states;
  let resState = Indian_states_cities_list.STATE_WISE_CITIES[states];
  res.status(200).send({ status: "alive", data: resState });
});

router.post("/lifecycle", (req, res) => {
  // console.log(req.body);
  res.send({
    status: "alive",
    date: moment().format(),
    token: process.env.TOKEN_SECRET,
  });
});

function generateAccessToken(username) {
  return jwt.sign(username, process.env.TOKEN_SECRET);
}

router.post("/checkmobile", async (req, res) => {
  // console.log(req.body);
  try {
    let userexist = await User.findOne({ mobile: req.body.mobile });
    if (userexist) {
      res.status(200).send({ msg: "user credential already exist" });
    } else {
      res.status(200).send({ msg: "user credential not exist" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

router.post("/createuser", async (request, response) => {
  // console.log(request.body);
  const data = request.body;
  // console.log("************");
  // console.log("createuser");
  // console.log("************");
  try {
    let user = await User.findOne({ mobile: request.body.mobile });
    if (user) {
      response.status(200).send({ msg: "User credential already exist" });
    } else {
      bcrypt.hash(data.password, saltRounds).then(async function (hash) {
        data.password = hash;
        // console.log(data);
        const appuser = new User(data);
        const result = await appuser.save();
        // console.log(result);

        //creating subscription details
        const subscription = await SubscriptionDetail.create({
          userId: result._id,
          creditAmount: 20,
          transactionsLeft: 3,
        });
        // if (subscription) {
        //   res.status(200).send({
        //     message: "Subcription details added",
        //     subscriptionDetails: subscription,
        //   });
        // } else {
        //   res.status(200).send({
        //     message: "Could not add subcription details",
        //   });
        // }

        response.status(200).send({ msg: "User Registed successfully" });
      });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

router.post("/auth", async (req, res) => {
  // console.log(req.body);
  try {
    // console.log("*****");
    // console.log("auth");
    // console.log("*****");
    let users = await User.findOne({ mobile: req.body.mobile });
    // console.log(users);
    if (users != null) {
      // let data = users;
      // data['password']="";
      bcrypt.compare(req.body.password, users.password).then(function (result) {
        if (result) {
          const token = generateAccessToken({
            mobile: req.body.mobile,
            userId: users._id,
            role: users.userType,
          });
          users.password = "";
          // console.log(result);
          res.status(200).send({
            msg: "Authenticated successfully",
            token: token,
            resdata: users,
            userId: users._id,
          });
        } else {
          res.status(200).send({ msg: "Invalid Credentials" });
        }
      });
    } else {
      res.status(200).send({ msg: "User doesn't exist" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//To get and view all the details of a user (in th eprofiule settings screen).
router.get("/getUserDetails", verifyAuthToken, async (req, res) => {
  try {
    // console.log("*****");
    // console.log("getUserDetails");
    // console.log("*****");
    let user = await User.findById(req.query.id);
    if (user) {
      user["password"] = "null";
      res.status(200).send({ message: "User found", userDetails: user });
    } else {
      res.status(200).send({ message: "User not found" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//To update the details of a user (in the profile settings screen).
//mobile,usertype can not be changed.
router.put("/updateUserDetails", verifyAuthToken, async (req, res) => {
  try {
    // console.log(req.body);
    let userUpdate = await User.updateOne(
      { mobile: req.body.mobile },
      {
        $set: {
          userName: req.body.userName,
          avatarUrl: req.body.avatarUrl,
          houseNoStreetName: req.body.houseNoStreetName,
          locality: req.body.locality,
          city: req.body.city,
          state: req.body.state,
          pincode: req.body.pincode,
        },
      }
    );
    if (userUpdate) {
      res
        .status(200)
        .send({ Message: "User updated", userUpdatedDetails: userUpdate });
    } else {
      res.status(200).send({ Message: "User not updated" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//To update the password details of a user (in the profile settings screen).
router.put(
  "/updateUserPassword",
  verifyAuthToken,
  async (request, response) => {
    // console.log("updateUserPassword Triggered");
    try {
      let user = await User.findOne({ mobile: request.body.mobile });
      if (user) {
        let currentPasswordCheck = await bcrypt.compare(
          request.body.currentPassword,
          user.password
        );
        if (currentPasswordCheck) {
          bcrypt
            .hash(request.body.newPassword, saltRounds)
            .then(async function (hash) {
              request.body.newPassword = hash;
              let userPasswordUpdate = await User.updateOne(
                { mobile: request.body.mobile },
                {
                  $set: {
                    password: request.body.newPassword,
                  },
                }
              );
              if (userPasswordUpdate) {
                response.status(200).send({ Message: "User password updated" });
              } else {
                response
                  .status(200)
                  .send({ Message: "User passowrd not updated" });
              }
            });
        } else {
          response.status(200).send({ Message: "Current password wrong" });
        }
      }
    } catch (error) {
      // console.log(error);
      response.status(500).send(error);
    }
  }
);

// ******* api not in web app use *****
//to reset password while forgot password
router.put("/forgotUserPassword", async (request, response) => {
  try {
    bcrypt.hash(request.body.password, saltRounds).then(async function (hash) {
      request.body.password = hash;
      let userPasswordUpdate = await User.updateOne(
        { mobile: request.body.mobile },
        {
          $set: {
            password: request.body.password,
          },
        }
      );
      if (userPasswordUpdate) {
        response.status(200).send({ Message: "User password updated" });
      } else {
        response.status(200).send({ Message: "User not updated" });
      }
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//give rating for user
router.put("/ratinguser", async (req, res) => {
  try {
    let finduser = await User.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.body.userId),
        },
      },
    ]);

    // console.log(finduser);

    if (finduser && finduser.length > 0) {
      let rate = finduser[0].ratings + req.body.rating;
      let ratedArr = finduser[0].ratedUser || [];
      ratedArr.push(req.body.raterId);
      // console.log(rate, ratedArr);
      let userUpdate = await User.updateOne(
        { _id: req.body.userId },
        {
          $set: {
            ratings: rate,
            ratedUser: ratedArr,
          },
        }
      );
      if (userUpdate) {
        res.status(200).send({ Message: "User Rated Successfully" });
      } else {
        res.status(200).send({ Message: "User not Rated" });
      }

      // response.status(200).send({"msg":"User Rated successfully"});
    } else {
      res.status(200).send({ msg: "Invalid Credential" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//give rating for product
router.put("/ratingproduct", async (req, res) => {
  try {
    let findPro = await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.body.productId),
        },
      },
    ]);

    // console.log(findPro);
    if (findPro && findPro.length > 0) {
      let rate = findPro[0].ratings + req.body.rating;
      let ratedArr = findPro[0].ratedUser || [];
      ratedArr.push(req.body.raterId);
      // console.log(rate, ratedArr);
      let productUpdate = await Product.updateOne(
        { _id: req.body.productId },
        {
          $set: {
            ratings: rate,
            ratedUser: ratedArr,
          },
        }
      );
      if (productUpdate) {
        res.status(200).send({ Message: "Product Rated Successfully" });
      } else {
        res.status(200).send({ Message: "Product not Rated" });
      }
    } else {
      res.status(200).send({ msg: "Invalid Credential" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

// get search suggestions
router.get("/getSearchSuggestions", async (req, res) => {
  // console.log(req.query);
  try {
    await Product.aggregate([
      // {
      //   $project: {
      //     productName:1,
      //     searchString: req.query.searchString,
      //     isSubstring: {
      //       $regexMatch: {
      //         input: "$productName",
      //         regex: req.query.searchString,
      //         options: "i",
      //       },
      //     },
      //   },
      // },
      {
        $addFields: {
          matched: {
            $regexMatch: {
              input: "$productName",
              regex: req.query.searchString,
              options: "i",
            },
          },
        },
      },
      {
        $match: {
          matched: true,
        },
      },
      { $group: { _id: null, uniqueValues: { $addToSet: "$productName" } } },
      // {
      //   $sort: { uniqueValues: 1 },
      // },
      // {
      //   $project: {
      //     matched: 0,
      //     // productName:1,
      //   },
      // },
    ]).then((value) => {
      res.status(200).send({
        message: "Products suggestions found",
        productSuggestions: value,
      });
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

// ***************api not use in web app ************

//get search results for a product
router.get("/getSearchResults", verifyAuthToken, async (req, res) => {
  try {
    // console.log(req.query);
    let limits = Number(req.query.productlimit);
    await Product.aggregate([
      {
        $match: {
          productName: req.query.searchTerm,
          availStatus: true,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "userId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $project: {
          productName: 1,
          basePrice: 1,
          quantityUnit: 1,
          productImages: 1,
          quantityPerLot: 1,
          producedDate: 1,
          "sellerDetails.city": 1,
          "sellerDetails.userName": 1,
        },
      },
    ])
      .limit(limits)
      .then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products list recieved",
            products: value,
          });
        } else {
          res.status(200).send({
            message: "No products found",
          });
        }
      });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

router.get("/getProducts", verifyAuthToken, async (req, res) => {
  try {
    let limit = Number(req.query.productlimit);
    await Product.aggregate([
      {
        $match: {
          availStatus: true,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "userId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $project: {
          productName: 1,
          basePrice: 1,
          quantityUnit: 1,
          productImages: 1,
          quantityPerLot: 1,
          producedDate: 1,
          "sellerDetails.city": 1,
          "sellerDetails.userName": 1,
        },
      },
    ])
      .limit(limit)
      .then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products list recieved",
            products: value,
          });
        } else {
          res.status(200).send({
            message: "No products available",
          });
        }
      });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

router.get("/getProductsName", verifyAuthToken, async (req, res) => {
  try {
    await Product.aggregate([
      {
        $match: {
          availStatus: true,
        },
      },
      {
        $group: {
          _id: "$productName", // Group by the product name
        },
      },
      {
        $project: {
          _id: 1,
          value: "$_id",
          label: "$_id",
        },
      },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Products name recieved",
          products: value,
        });
      } else {
        res.status(200).send({
          message: "No products available",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get search results using filters
router.post("/getSearchResultsByFilters", verifyAuthToken, async (req, res) => {
  try {
    var locationList = req.body.locationList;
    var priceRange = req.body.priceRange;
    var producedDateRange = req.body.producedDateRange;
    var availableFromDateRange = req.body.availableFromDateRange;
    let searchkey = req.query.searchTerm;

    // console.log("*******************************");
    // console.log("getSearchResultsByFilters");
    // console.log("locationList : " + Array(locationList));
    // console.log("producedDaterange : " + producedDateRange);
    // console.log("availableFromDateRange : " + availableFromDateRange);
    var prodDate1 = new Date(producedDateRange[0]);
    var prodDate2 = new Date(producedDateRange[1]);
    // let prodDate1 ="";
    // let prodDate2 = "";
    var availDate1 = new Date(availableFromDateRange[0]);
    var availDate2 = new Date(availableFromDateRange[1]);
    // console.log("Price range : " + Array(priceRange));
    var price1 = Number(priceRange[0]);
    var price2 = Number(priceRange[1]);
    // console.log("price1 : " + price1);
    // console.log("price2 : " + price2);
    console.log(prodDate1 < prodDate2); // returns true if pordDate1 is before prodDate2
    // console.log("*******************************");
    // console.log("term", searchkey);
    await Product.aggregate([
      {
        $match: {
          productName: req.query.searchTerm,
          availStatus: true,
          producedDate: {
            $gte: prodDate1,
            $lte: prodDate2,
          },
          availableFrom: {
            $gte: availDate1,
            $lte: availDate2,
          },
          basePrice: {
            $gte: price1,
            $lte: price2,
          },
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "userId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $match: {
          "sellerDetails.city": {
            $in: locationList,
          },
        },
      },
      {
        $project: {
          productName: 1,
          basePrice: 1,
          quantityPerLot: 1,
          quantityUnit: 1,
          productImages: 1,
          producedDate: 1,
          "sellerDetails.city": 1,
          "sellerDetails.userName": 1,
        },
      },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Products list recieved",
          products: value,
        });
      } else {
        res.status(200).send({
          message: "No products found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get search results using sort
router.get("/getSearchResultsBySort", verifyAuthToken, async (req, res) => {
  try {
    var sortAccordingTo = req.query.sortAccordingTo;
    var closestFarthest = Number(req.query.closestFarthest);
    // console.log("*******************************");
    // console.log("getSearchResultsBySort");
    // console.log("sortAccordingTo : " + sortAccordingTo);
    // console.log("*******************************");

    if (sortAccordingTo == "producedDate") {
      await Product.aggregate([
        {
          $match: {
            productName: req.query.searchTerm,
            availStatus: true,
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $sort: { producedDate: closestFarthest },
        },
        {
          $project: {
            _id: 1,
            productName: 1,
            basePrice: 1,
            quantityPerLot: 1,
            quantityUnit: 1,
            productImages: 1,
            producedDate: 1,
            "sellerDetails.userName": 1,
            "sellerDetails.city": 1,
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products list recieved",
            products: value,
          });
        } else {
          res.status(200).send({
            message: "No products found",
          });
        }
      });
    } else if (sortAccordingTo == "availableFrom") {
      await Product.aggregate([
        {
          $match: {
            productName: req.query.searchTerm,
            availStatus: true,
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $sort: { availableFrom: closestFarthest },
        },
        {
          $project: {
            _id: 1,
            productName: 1,
            basePrice: 1,
            quantityPerLot: 1,
            quantityUnit: 1,
            productImages: 1,
            producedDate: 1,
            "sellerDetails.userName": 1,
            "sellerDetails.city": 1,
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products list recieved",
            products: value,
          });
        } else {
          res.status(200).send({
            message: "No products found",
          });
        }
      });
    } else if (sortAccordingTo == "basePrice") {
      await Product.aggregate([
        {
          $match: {
            productName: req.query.searchTerm,
            availStatus: true,
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $sort: { basePrice: closestFarthest },
        },
        {
          $project: {
            _id: 1,
            productName: 1,
            basePrice: 1,
            quantityPerLot: 1,
            quantityUnit: 1,
            productImages: 1,
            producedDate: 1,
            "sellerDetails.userName": 1,
            "sellerDetails.city": 1,
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products list recieved",
            products: value,
          });
        } else {
          res.status(200).send({
            message: "No products found",
          });
        }
      });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//Loads all the details of a product
router.get("/getProductDetails", verifyAuthToken, async (request, response) => {
  try {
    await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(request.query.id),
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "userId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $project: {
          _id: 1,
          productName: 1,
          basePrice: 1,
          quantityPerLot: 1,
          quantityUnit: 1,
          minNoLot: 1,
          productDesc: 1,
          productImages: 1,
          producedDate: 1,
          availableFrom: 1,
          reviews: 1,
          ratings: 1,
          ratedUser: 1,
          location: 1,
          availStatus: 1,
          "sellerDetails._id": 1,
          "sellerDetails.userName": 1,
          "sellerDetails.mobile": 1,
          "sellerDetails.city": 1,
        },
      },
    ]).then((product) => {
      // if (product.length > 0) {
      response
        .status(200)
        .send({ message: "Product details found", productDetails: product });
      // } else {
      // response.status(200).send({ message: "No product details found" });
      // }
    });
    // if (product) {
    //   response
    //     .status(200)
    //     .send({ message: "Product found", productDetails: product });
    // } else {
    //   response.status(200).send({ message: "Product not found" });
    // }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//to get products bids
router.get("/getProductBids", verifyAuthToken, async (req, res) => {
  try {
    await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.query.productId),
          availStatus: true,
        },
      },
      {
        $lookup: {
          from: "orders",
          localField: "_id",
          foreignField: "productId",
          as: "orderDetails",
        },
      },
      {
        $unwind: {
          path: "$orderDetails",
        },
      },
      {
        $match: {
          "orderDetails.isClosed": false,
        },
      },
      // {
      //   $project: {
      //     _id: 1,
      //     productName: 1,
      //     basePrice: 1,
      //     "orderDetails.dealPrice": 1,
      //     "orderDetails.isClosed": 1,
      //   },
      // },
      // {
      //   $unwind: {
      //     path: "$orderDetails",
      //   },
      // },
      {
        $group: {
          // _id: "$orderDetails.dealPrice",
          _id: null,
          count: { $sum: 1 },
          max: { $max: "$orderDetails.dealPrice" },
          min: { $min: "$orderDetails.dealPrice" },
          avg: { $avg: "$orderDetails.dealPrice" },
        },
      },
      // {
      //   $count: "count",
      // },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Product bids received",
          productBids: value,
        });
      } else {
        res.status(200).send({
          message: "No bids found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

// ***************api not use in web app start************

//get products available list of locations
router.get("/getProductLocationList", verifyAuthToken, async (req, res) => {
  try {
    await Product.aggregate([
      {
        $match: {
          productName: req.query.searchTerm,
          availStatus: true,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "userId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $unwind: {
          path: "$sellerDetails",
        },
      },
      {
        $group: {
          _id: "$sellerDetails.city",
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Products locations received",
          locationsList: value,
        });
      } else {
        res.status(200).send({
          message: "No locations found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get products produced date list
router.get("/getProductProducedDatesList", async (req, res) => {
  try {
    await Product.aggregate([
      {
        $match: {
          productName: req.query.searchTerm,
          availStatus: true,
        },
      },
      {
        $group: {
          _id: null,
          max: { $max: "$producedDate" },
          min: { $min: "$producedDate" },
        },
      },
      // {
      //   $sort: { _id: 1 },
      // },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Products produced dates received",
          producedDatesRange: value,
        });
      } else {
        res.status(200).send({
          message: "No dates found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get fav products list
router.get("/getFavoriteProducts", async (req, res) => {
  try {
    const user = await User.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(req.query.buyerId) } },
    ]);

    var productDetails = [];

    for (var i = 0; i < user[0]["favoriteProducts"].length; i++) {
      await Product.aggregate([
        {
          $match: {
            _id: new mongoose.Types.ObjectId(user[0]["favoriteProducts"][i]),
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $project: {
            _id: 1,
            basePrice: 1,
            productImages: 1,
            productName: 1,
            quantityUnit: 1,
            "sellerDetails.city": 1,
            "sellerDetails.userName": 1,
          },
        },
      ]).then((value) => {
        if (value.length > 0) {
          productDetails.push(value);
        }
        // res.status(200).send({
        //   message: "Fav products details recieved",
        //   favProducts: value,
        // });
      });
    }

    // .then((value) => {
    console.log(value);
    res.status(200).send({
      message: "Fav products recieved",
      productDetails: productDetails,
    });
    // });
  } catch (err) {
    // console.log(err);
    res.send(500).error(err);
  }
});

router.get("/getProductsListMinDetails", async (request, response) => {
  try {
    await User.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(request.query.userId),
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "_id",
          foreignField: "userId",
          as: "productDetails",
        },
      },
      {
        $project: {
          _id: 1,
          userName: 1,
          city: 1,
          "productDetails._id": 1,
          "productDetails.productName": 1,
          "productDetails.basePrice": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productImages": 1,
        },
      },
    ]).then((product) => {
      response.status(200).send({
        message: "Product list min details found",
        productsListMinDetails: product,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get products prices
router.get("/getProductPriceList", async (req, res) => {
  try {
    await Product.aggregate([
      {
        $match: {
          productName: req.query.searchTerm,
          availStatus: true,
        },
      },
      // {
      //   $lookup: {
      //     from: "users",
      //     localField: "userId",
      //     foreignField: "_id",
      //     as: "sellerDetails",
      //   },
      // },
      // {
      //   $unwind: {
      //     path: "$",
      //   },
      // },
      {
        $group: {
          _id: null,
          // prices: {
          //   $addToSet: "$basePrice",
          // },
          // count: { $sum: 1 },
          max: { $max: "$basePrice" },
          min: { $min: "$basePrice" },
        },
      },
      // {
      //   $project: {
      //     _id: 0,
      //     prices: 1,
      //   },
      // },
    ]).then((value) => {
      if (value.length != 0) {
        res.status(200).send({
          message: "Products prices received",
          pricesList: value,
        });
      } else {
        res.status(200).send({
          message: "No prices found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});
// ***************api not use in web app end ************

//get products available date list
router.get(
  "/getProductAvailableDatesList",
  verifyAuthToken,
  async (req, res) => {
    try {
      await Product.aggregate([
        {
          $match: {
            productName: req.query.searchTerm,
            availStatus: true,
          },
        },
        {
          $group: {
            _id: null,
            maxAvailDate: { $max: "$availableFrom" },
            minAvailDate: { $min: "$availableFrom" },
            maxProducedDate: { $max: "$producedDate" },
            minProducedDate: { $min: "$producedDate" },
            max: { $max: "$basePrice" },
            min: { $min: "$basePrice" },
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "Products available from dates received",
            availableFromDatesRange: value,
          });
        } else {
          res.status(200).send({
            message: "No dates found",
          });
        }
      });
    } catch (error) {
      // console.log(error);
      res.status(500).send(error);
    }
  }
);

//toggle favorites
router.put("/toggleFavorites", verifyAuthToken, async (req, res) => {
  try {
    let user = await User.findOne({ _id: req.body.userId });
    // if(user.favoriteProducts.includes(req.body.productId)){
    var index = user.favoriteProducts.indexOf(req.body.productId);
    var userUpdate;
    // console.log("Index : " + index);
    if (index > -1) {
      // console.log(user.favoriteProducts);
      user.favoriteProducts.splice(index, 1);
      // console.log(user.favoriteProducts);

      userUpdate = await user.updateOne({
        $set: {
          favoriteProducts: user.favoriteProducts,
        },
      });
    } else {
      // console.log(user.favoriteProducts);
      user.favoriteProducts.push(
        new mongoose.Types.ObjectId(req.body.productId)
      );
      // console.log(user.favoriteProducts);

      userUpdate = await user.updateOne({
        $set: {
          favoriteProducts: user.favoriteProducts,
        },
      });
    }
    // }
    let Updateduser = await User.findOne({ _id: req.body.userId });
    Updateduser["password"] = "none";
    if (userUpdate) {
      res.status(200).send({
        message: "User favorites updated",
        updatedata: Updateduser,
      });
    } else {
      res.status(200).send({
        message: "User favorites not updated",
      });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

router.get("/getfavproducts", verifyAuthToken, async (req, res) => {
  try {
    const results = await User.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(req.query.buyerId) } },
      {
        $lookup: {
          from: "products", // The name of the product collection
          localField: "favoriteProducts",
          foreignField: "_id",
          as: "favprod",
        },
      },
      {
        $project: {
          userName: 1,
          city: 1,
          // favproductDetails: 1,
          "favprod._id": 1,
          "favprod.basePrice": 1,
          "favprod.producedDate": 1,
          "favprod.productImages": 1,
          "favprod.productName": 1,
          "favprod.quantityPerLot": 1,
          "favprod.quantityUnit": 1,
        },
      },
    ]).then((value) => {
      // console.log(value);
      res.status(200).send({
        message: "Fav products details recieved",
        favProducts: value[0],
      });
    });
  } catch (err) {
    // console.log(err);
    res.send(500).error(err);
  }
});

//create an order
router.post("/createOrder", verifyAuthToken, async (req, res) => {
  try {
    let seller = await User.findOne({ mobile: req.body.sellerMobile });
    const order = await Order.create({
      sellerId: seller._id,
      buyerId: req.body.buyerId,
      productId: req.body.productId,
      basePrice: req.body.basePrice,
      dealPrice: req.body.dealPrice,
      orderQtyLots: req.body.orderQtyLots,
      orderValue: req.body.orderValue,
      isOrderAccepted: req.body.isOrderAccepted,
      paymentMode: req.body.paymentMode,
      halfPaymentDone: req.body.halfPaymentDone,
      fullPaymentDone: req.body.fullPaymentDone,
      isClosed: req.body.isClosed,
      closedOn: req.body.closedOn,
      buyerClosedOn: req.body.buyerClosedOn,
      isBuyerClosed: req.body.isBuyerClosed,
      isSellerClosed: req.body.isSellerClosed,
      sellerClosedOn: req.body.sellerClosedOn,
      requiredOnOrBefore: req.body.requiredOnOrBefore,
      expectingResponseBefore: req.body.expectingResponseBefore,
    });
    res.status(200).send({ message: "Order placed", orderDetails: order });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get an order details
router.get("/getOrderDetails", verifyAuthToken, async (req, res) => {
  // console.log(req.query);
  try {
    await Order.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.query.id),
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          createdAt: 1,
          updatedAt: 1,
          orderValue: 1,
          orderQtyLots: 1,
          closedOn: 1,
          requiredOnOrBefore: 1,
          expectingResponseBefore: 1,
          paymentMode: 1,
          orderValue: 1,
          isOrderAccepted: 1,
          isClosed: 1,
          isSellerClosed: 1,
          sellerClosedOn: 1,
          isBuyerClosed: 1,
          buyerClosedOn: 1,
          "buyerDetails._id": 1,
          "buyerDetails.userName": 1,
          "buyerDetails.mobile": 1,
          "sellerDetails.userName": 1,
          "sellerDetails._id": 1,
          "sellerDetails.mobile": 1,
          "productDetails._id": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.basePrice": 1,
          "productDetails.minNoLot": 1,
          "productDetails.quantityPerLot": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "Orders details recieved",
        orderDetails: value,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//update an order's details
router.put("/updateOrderDetails", verifyAuthToken, async (req, res) => {
  try {
    // console.log("Update order details", req.body);

    let findOrder = await Order.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.body.id),
        },
      },
    ]);

    if (findOrder && findOrder.length > 0) {
      // console.log(findOrder);
      if (req.body.isOrderAccepted && !findOrder.isOrderAccepted) {
        // won't trigger if isOrderAccepted is false
        // console.log(
        //   "req.body.isOrderAccepted received : " + req.body.isOrderAccepted
        // );
        //for seller
        var sellerCurrentSubscriptionDetails = await SubscriptionDetail.findOne(
          {
            userId: findOrder[0].sellerId,
          }
        );
        // console.log(sellerCurrentSubscriptionDetails);
        var sellerCurrentTransactionsLimit =
          sellerCurrentSubscriptionDetails["transactionsLeft"];
        var sellerNewTransactionsLimit = sellerCurrentTransactionsLimit - 1;
        // if (sellerNewTransactionsLimit < 0) {
        //   sellerNewTransactionsLimit = 0;
        // }
        if (sellerCurrentTransactionsLimit % 4 == 0) {
          // limits = 3,2,1,0 - Zero Based
          var sellerCurrentCreditAmount =
            sellerCurrentSubscriptionDetails["creditAmount"];
          var sellerNewCreditAmount = sellerCurrentCreditAmount - 20;
          await SubscriptionDetail.updateOne(
            { userId: findOrder[0].sellerId },
            {
              transactionsLeft: sellerNewTransactionsLimit,
              creditAmount: sellerNewCreditAmount,
            }
          );
        } else {
          await SubscriptionDetail.updateOne(
            { userId: findOrder[0].sellerId },
            {
              transactionsLeft: sellerNewTransactionsLimit,
            }
          );
        }

        //for buyer
        var buyerCurrentSubscriptionDetails = await SubscriptionDetail.findOne({
          userId: findOrder[0].buyerId,
        });
        // console.log(buyerCurrentSubscriptionDetails["transactionsLeft"]);
        var buyerCurrentTransactionsLimit =
          buyerCurrentSubscriptionDetails["transactionsLeft"];
        var buyerNewTransactionsLimit = buyerCurrentTransactionsLimit - 1;
        // if (buyerNewTransactionsLimit < 0) {
        //   buyerNewTransactionsLimit = 0;
        // }
        if (buyerCurrentTransactionsLimit % 4 == 0) {
          // limits = 3,2,1,0 - Zero Based
          var buyerCurrentCreditAmount =
            buyerCurrentSubscriptionDetails["creditAmount"];
          var buyerNewCreditAmount = buyerCurrentCreditAmount - 20;
          await SubscriptionDetail.updateOne(
            { userId: findOrder[0].buyerId },
            {
              transactionsLeft: buyerNewTransactionsLimit,
              creditAmount: buyerNewCreditAmount,
            }
          );
        } else {
          await SubscriptionDetail.updateOne(
            { userId: findOrder[0].buyerId },
            {
              transactionsLeft: buyerNewTransactionsLimit,
            }
          );
        }
      }

      const orderUpdate = await Order.findByIdAndUpdate(req.body.id, req.body);
      if (orderUpdate) {
        res
          .status(200)
          .send({ message: "Order updated", orderDetails: orderUpdate });
      } else {
        res.status(200).send({ message: "Order not found" });
      }
      // res.status(200).send({ message: "isOrderAccepted" });
    } else {
      res.status(200).send({ message: "Order not found" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get orders history
router.get("/getOrdersHistory", verifyAuthToken, async (req, res) => {
  // console.log("************getOrdersHistory Start************");
  try {
    await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: true,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      { $sort: { createdAt: -1 } },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          createdAt: 1,
          updatedAt: 1,
          orderValue: 1,
          orderQtyLots: 1,
          closedOn: 1,
          requiredOnOrBefore: 1,
          expectingResponseBefore: 1,
          isOrderAccepted: 1,
          paymentMode: 1,
          halfPaymentDone: 1,
          fullPaymentDone: 1,
          basePrice: 1,
          isClosed: 1,
          isSellerClosed: 1,
          isBuyerClosed: 1,
          isOrderAccepted: 1,
          "sellerDetails._id": 1,
          "sellerDetails.userName": 1,
          "sellerDetails.mobile": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.quantityUnit": 1,
          "productDetails._id": 1,
          "productDetails.minNoLot": 1,
          "productDetails.quantityPerLot": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "Orders history recieved",
        orderDetails: value,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
  // console.log("************getOrdersHistory End************");
});

//get active orders for buyers
router.get("/getActiveOrders", verifyAuthToken, async (req, res) => {
  // console.log("************getActiveOrders Start************");
  // console.log(req.query);
  try {
    await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: true,
          isSellerClosed: false,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      { $sort: { createdAt: -1 } },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          createdAt: 1,
          updatedAt: 1,
          orderValue: 1,
          orderQtyLots: 1,
          closedOn: 1,
          requiredOnOrBefore: 1,
          expectingResponseBefore: 1,
          isOrderAccepted: 1,
          paymentMode: 1,
          halfPaymentDone: 1,
          fullPaymentDone: 1,
          basePrice: 1,
          isClosed: 1,
          isSellerClosed: 1,
          isBuyerClosed: 1,
          sellerClosedOn: 1,
          buyerClosedOn: 1,
          "sellerDetails._id": 1,
          "sellerDetails.userName": 1,
          "sellerDetails.mobile": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.quantityUnit": 1,
          "productDetails._id": 1,
          "productDetails.minNoLot": 1,
          "productDetails.quantityPerLot": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "Active orders recieved",
        orderDetails: value,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
  // console.log("************getActiveOrders End************");
});

//get pending orders for buyers
router.get("/getPendingOrders", verifyAuthToken, async (req, res) => {
  // console.log("************getPendingOrders Start************");
  // console.log(req.query);
  try {
    await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: false,
          isSellerClosed: false,
          isBuyerClosed: false,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      { $sort: { createdAt: -1 } },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          createdAt: 1,
          updatedAt: 1,
          orderValue: 1,
          orderQtyLots: 1,
          closedOn: 1,
          requiredOnOrBefore: 1,
          expectingResponseBefore: 1,
          isOrderAccepted: 1,
          paymentMode: 1,
          halfPaymentDone: 1,
          fullPaymentDone: 1,
          basePrice: 1,
          isClosed: 1,
          isSellerClosed: 1,
          isBuyerClosed: 1,
          sellerClosedOn: 1,
          buyerClosedOn: 1,
          "sellerDetails._id": 1,
          "sellerDetails.userName": 1,
          "sellerDetails.mobile": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.quantityUnit": 1,
          "productDetails._id": 1,
          "productDetails.minNoLot": 1,
          "productDetails.quantityPerLot": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "Pending orders recieved",
        orderDetails: value,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
  // console.log("************getPendingOrders End************");
});

//get flagged orders
router.get("/getFlaggedOrders", verifyAuthToken, async (req, res) => {
  // console.log("************getFlaggedOrders Start************");
  try {
    await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: true,
          isSellerClosed: true,
          isBuyerClosed: false,
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "sellerDetails",
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      { $sort: { createdAt: -1 } },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          createdAt: 1,
          updatedAt: 1,
          orderValue: 1,
          orderQtyLots: 1,
          closedOn: 1,
          requiredOnOrBefore: 1,
          expectingResponseBefore: 1,
          isOrderAccepted: 1,
          paymentMode: 1,
          halfPaymentDone: 1,
          fullPaymentDone: 1,
          basePrice: 1,
          isClosed: 1,
          isSellerClosed: 1,
          isBuyerClosed: 1,
          sellerClosedOn: 1,
          buyerClosedOn: 1,
          "sellerDetails._id": 1,
          "sellerDetails.userName": 1,
          "sellerDetails.mobile": 1,
          "productDetails.quantityUnit": 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.quantityUnit": 1,
          "productDetails._id": 1,
          "productDetails.minNoLot": 1,
          "productDetails.quantityPerLot": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "Flagged orders recieved",
        orderDetails: value,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
  // console.log("************getFlaggedOrders End************");
});

//reject incoming order
router.get("/rejectOrder", verifyAuthToken, async (request, response) => {
  // console.log("reject orders", request.query);
  try {
    const orderDelete = await Order.deleteOne({ _id: request.query.orderId });
    // console.log(orderDelete);
    if (orderDelete && orderDelete.deletedCount) {
      response.status(200).send({ message: "Order rejected successfully" });
    } else {
      response.status(200).send({ message: "Invalid order id" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//Reviews
//post a review
router.post("/postProductReview", async (req, res) => {
  try {
    const review = await ProductReview.create(req.body);
    if (review) {
      res.status(200).send({ message: "Review posted", review: review });
    } else {
      res.status(200).send({ message: "Unable to post review" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get a review
router.get("/getProductReview", async (req, res) => {
  try {
    const review = await ProductReview.findById(req.body.id);
    if (review) {
      res.status(200).send({ message: "Review found", review: review });
    } else {
      res.status(200).send({ message: "Review not found" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//Post a user review
router.post("/postUserReview", verifyAuthToken, async (req, res) => {
  try {
    const userReview = await UserReview.create(req.body);
    if (userReview) {
      res
        .status(200)
        .send({ message: "Review posted", userReview: userReview });
    } else {
      res.status(200).send({ message: "Unable to post review" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

// Get a user review
router.get("/getUserReview", verifyAuthToken, async (req, res) => {
  try {
    var limit = Number(req.query.noOfReviews);
    await UserReview.aggregate([
      {
        $match: {
          postedFor: new mongoose.Types.ObjectId(req.query.postedFor),
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "postedBy",
          foreignField: "_id",
          as: "postedByDetails",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "postedFor",
          foreignField: "_id",
          as: "postedForDetails",
        },
      },
      {
        $project: {
          _id: 1,
          review: 1,
          reply: 1,
          createdAt: 1,
          "postedByDetails._id": 1,
          "postedByDetails.userName": 1,
          "postedForDetails._id": 1,
          "postedForDetails.userName": 1,
        },
      },
    ]).then((value) => {
      res.status(200).send({
        message: "User reviews recieved",
        userReviews: value,
      });
    });
    // if (userReview) {
    //   res.status(200).send({ message: "Review found", userReview: userReview });
    // } else {
    //   res.status(200).send({ message: "Review not found" });
    // }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

router.get("/getPostedUserReview", async (req, res) => {
  try {
    var limit = Number(req.query.noOfReviews);
    await UserReview.aggregate([
      {
        $match: {
          postedBy: new mongoose.Types.ObjectId(req.query.postedBy),
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "postedFor",
          foreignField: "_id",
          as: "postedForDetails",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "postedFor",
          foreignField: "_id",
          as: "postedForDetails",
        },
      },
      {
        $project: {
          _id: 1,
          review: 1,
          reply: 1,
          createdAt: 1,
          "postedByDetails._id": 1,
          "postedByDetails.userName": 1,
          "postedForDetails._id": 1,
          "postedForDetails.userName": 1,
        },
      },
    ]).then((value) => {
      if (value.length > 0) {
        res.status(200).send({
          message: "User reviews recieved",
          userReviews: value,
        });
      } else {
        res.status(200).send({
          message: "No user reviews found",
        });
      }
    });
    // if (userReview) {
    //   res.status(200).send({ message: "Review found", userReview: userReview });
    // } else {
    //   res.status(200).send({ message: "Review not found" });
    // }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get userreview by limit
router.get("/getUserReviewByLimit", verifyAuthToken, async (req, res) => {
  try {
    // console.log("getUserReviewByLimit");
    var limit = Number(req.query.noOfReviews);
    if (limit == 0) {
      await UserReview.aggregate([
        {
          $match: {
            postedFor: new mongoose.Types.ObjectId(req.query.postedFor),
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "postedBy",
            foreignField: "_id",
            as: "postedByDetails",
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "postedFor",
            foreignField: "_id",
            as: "postedForDetails",
          },
        },
        {
          $project: {
            _id: 1,
            review: 1,
            reply: 1,
            createdAt: 1,
            "postedByDetails._id": 1,
            "postedByDetails.userName": 1,
            "postedForDetails._id": 1,
            "postedForDetails.userName": 1,
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          res.status(200).send({
            message: "User reviews by limit recieved",
            userReviews: value,
          });
        } else {
          res.status(200).send({
            message: "User reviews not found",
          });
        }
        ``;
      });
    } else {
      await UserReview.aggregate([
        {
          $match: {
            postedFor: new mongoose.Types.ObjectId(req.query.postedFor),
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "postedBy",
            foreignField: "_id",
            as: "postedByDetails",
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "postedFor",
            foreignField: "_id",
            as: "postedForDetails",
          },
        },
        {
          $project: {
            _id: 1,
            review: 1,
            reply: 1,
            createdAt: 1,
            "postedByDetails._id": 1,
            "postedByDetails.userName": 1,
            "postedForDetails._id": 1,
            "postedForDetails.userName": 1,
          },
        },
      ])
        .limit(limit)
        .then((value) => {
          if (value.length != 0) {
            res.status(200).send({
              message: "User reviews by limit recieved",
              userReviews: value,
            });
          } else {
            res.status(200).send({
              message: "User reviews not found",
            });
          }
        });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//reply to review
router.put("/replyToUserReview", verifyAuthToken, async (req, res) => {
  try {
    // console.log("replyToUserReview - common");
    let review = await UserReview.updateOne(
      { _id: req.body.id },
      {
        $set: {
          reply: req.body.reply,
        },
      }
    );

    if (review) {
      res.status(200).send({ message: "Reply set", review: review });
    } else {
      res.status(200).send({ message: "Review not found" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//check if deal closed for posting review
router.get("/checkIfDealClosed", verifyAuthToken, async (req, res) => {
  try {
    // console.log("checkIfDealClosed");
    await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.sellerId),
          buyerId: new mongoose.Types.ObjectId(req.query.buyerId),
          isClosed: true,
        },
      },
    ]).then((value) => {
      if (value.length > 0) {
        res.status(200).send({
          message: "User deal closed",
        });
      } else {
        res.status(200).send({
          message: "User deal not closed",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//delete a user review
router.delete("/deleteUserReview", async (req, res) => {
  try {
    let reviewDelete = await UserReview.deleteOne({ _id: req.body.id });
    if (reviewDelete) {
      res.status(200).send({
        message: "User review deleted",
      });
    } else {
      res.status(200).send({
        message: "User review not deleted",
      });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//dashboard counts
router.post("/getcounts", async (req, res) => {
  try {
    let products = await Product.countDocuments({
      userId: new mongoose.Types.ObjectId(req.body.userid),
    });
    let orders = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.body.userid), // Match the given user ID
        },
      },
      {
        $group: {
          _id: "$sellerId", // Group by the "status" field
          totalCount: { $sum: 1 }, // Count total orders in each group
          completedCount: {
            $sum: { $cond: [{ $eq: ["$isClosed", true] }, 1, 0] }, // Count completed orders in each group
          },
          incompleteCount: {
            $sum: { $cond: [{ $eq: ["$isClosed", false] }, 1, 0] }, // Count incomplete orders in each group
          },
        },
      },
    ]);

    // console.log(orders, products);
    if (orders && products) {
      res.status(200).send({
        message: "counted",
        data: {
          orderCount: orders,
          productcount: products,
        },
      });
    } else {
      res.status(200).send({
        message: "not Counted",
      });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//update documents with new feilds
router.get("/updateAllDocuments", async (req, res) => {
  try {
    var order = await Order.updateMany(
      {},
      {
        $set: {
          isSellerClosed: true,
          isBuyerClosed: true,
          sellerClosedOn: Date.now(),
          buyerClosedOn: Date.now(),
        },
      },
      { upsert: false, multi: true }
    );
    if (order) {
      res.status(200).send({ result: "Done" });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//dashboard stats
router.get("/getDashboardStats", verifyAuthToken, async (req, res) => {
  try {
    //no. of products
    // let productCount = await Product.countDocuments({
    //   userId: new mongoose.Types.ObjectId(req.query.userId),
    // });

    //total buy value
    let totalBuyValue = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
          isSellerClosed: true,
          isBuyerClosed: true,
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalSales: { $sum: "$orderValue" },
        },
      },
    ]);

    //top products bought
    let topProductsBought = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
          isSellerClosed: true,
          isBuyerClosed: true,
          isOrderAccepted: true,
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      {
        $group: {
          _id: "$productDetails._id",
          totalSales: { $sum: "$orderValue" },
        },
      },
      {
        $sort: {
          totalSales: -1,
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "_id",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      {
        $project: {
          _id: 1,
          totalSales: 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.basePrice": 1,
          "productDetails.quantityUnit": 1,
        },
      },
    ]).limit(3);

    //recent orders
    let recentPlacedOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: false,
          isBuyerClosed: false,
          isOrderAccepted: false,
        },
      },
      // {
      //   $lookup: {
      //     from: "products",
      //     localField: "productId",
      //     foreignField: "_id",
      //     as: "productDetails",
      //   },
      // },
      // {
      //   $group: {
      //     _id: "$productDetails._id",
      //     totalSales: { $sum: "$orderValue" },
      //   },
      // },
      {
        $sort: {
          createdAt: -1,
        },
      },
      {
        $lookup: {
          from: "products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "sellerId",
          foreignField: "_id",
          as: "userDetails",
        },
      },
      {
        $project: {
          _id: 1,
          dealPrice: 1,
          orderValue: 1,
          expectingResponseBefore: 1,
          "productDetails.productName": 1,
          "productDetails.productImages": 1,
          "productDetails.basePrice": 1,
          "productDetails.quantityUnit": 1,
          "userDetails.userName": 1,
        },
      },
    ]).limit(3);

    //Orders stats
    let totalOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let completedOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
          isSellerClosed: true,
          isBuyerClosed: true,
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    //acceptedOrders
    let acceptedOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let rejectedOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
          isSellerClosed: false,
          isBuyerClosed: false,
          isOrderAccepted: false,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let pendingOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: false,
          isBuyerClosed: false,
          isOrderAccepted: false,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let activeOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: false,
          isBuyerClosed: false,
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let flagWaitingSellerApprovalOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: false,
          isBuyerClosed: true,
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    let flagedOrders = await Order.aggregate([
      {
        $match: {
          buyerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: true,
          isBuyerClosed: false,
          isOrderAccepted: true,
        },
      },
      {
        $group: {
          _id: null,
          totalCount: { $sum: 1 },
        },
      },
    ]);

    // console.log(
    //   totalOrders,
    //   completedOrders,
    //   rejectedOrders,
    //   // productCount,
    //   pendingOrders,
    //   activeOrders,
    //   flagWaitingSellerApprovalOrders,
    //   flagedOrders
    // );
    // if (totalOrders && productCount) {
    res.status(200).send({
      message: "Dashboard stats received",
      data: {
        // productCount: productCount,
        totalBuyValue: totalBuyValue,
        topProductsBought: topProductsBought,
        recentPlacedOrders: recentPlacedOrders,
        totalOrders: totalOrders,
        completedOrders: completedOrders,
        acceptedOrders: acceptedOrders,
        rejectedOrders: rejectedOrders,
        pendingOrders: pendingOrders,
        activeOrders: activeOrders,
        flagWaitingSellerApprovalOrders: flagWaitingSellerApprovalOrders,
        flagedOrders: flagedOrders,
      },
    });
    // } else {
    //   res.status(200).send({
    //     message: "not Counted",
    //   });
    // }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

module.exports = router;
