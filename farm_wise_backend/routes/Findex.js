const Product = require("../model/product");
const User = require("../model/user");
const mongoose = require("mongoose");
// const bcrypt = require('bcrypt');
// const saltRounds = 10;
const dotenv = require("dotenv");
const jwt = require("jsonwebtoken");

const Order = require("../model/order");
const UserReview = require("../model/userReview");
const verifyAuthToken = require("../middleware/verifyAuthToken");
dotenv.config();
// var moment = require('moment');

const router = require("express").Router({
  caseSensitive: true,
});

router.get("/farmeralive", (req, res) => {
  // console.log("alive called");
  res.status(200).send({ status: "alive" });
});



//products API
//add Product
router.post("/addproduct",verifyAuthToken, async (request, response) => {
  // console.log("addpro-api");
  try {
    let finduser = await User.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(request.body.userId),
        },
      },
    ]);
    // console.log(finduser);
    if (finduser && finduser.length > 0) {
      const appuser = new Product(request.body);
      const result = await appuser.save();
      // console.log(result);
      response.status(200).send({ msg: "Product Added successfully" });
    } else {
      response.status(200).send({ msg: "Invalid Credential" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});
//updateproduct
router.post("/updateproduct",verifyAuthToken, async (req, response) => {
  try {
    // console.log("updateproduct body data");
    // console.log(req.body);
    let finduser = await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.body.productId),
        },
      },
    ]);
    console.log(finduser.length);
    if (finduser && finduser.length > 0) {
      let user = await Product.updateOne(
        { _id: req.body.productId },
        {
          $set: {
            quantityPerLot: req.body.quantityPerLot,
            basePrice: req.body.basePrice,
            quantityUnit: req.body.quantityUnit,
            minNoLot: req.body.minNoLot,
            productDesc: req.body.productDesc,
            productImages: req.body.productImages,
            producedDate: req.body.producedDate,
            availableFrom: req.body.availableFrom,
            availStatus: req.body.availStatus,
          },
        }
      );
      // console.log("users");
      // console.log(user);
      response.status(200).send({ msg: "Product Updated Successfully" });
    } else {
      response.status(200).send({ msg: "Invalid Product ID" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//delete Product
router.post("/deleteproduct",verifyAuthToken, async (request, response) => {
  // console.log("delPro-api");
  try {
    let finduser = await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(request.body.productId),
        },
      },
    ]);
    // console.log(finduser.length);
    if (finduser && finduser.length > 0) {
      const appuser = await Product.deleteOne({ _id: request.body.productId });
      // console.log(appuser);
      response.status(200).send({ msg: "Product Removed successfully" });
    } else {
      response.status(200).send({ msg: "Invalid Product ID" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get all products
router.post("/getallproducts",verifyAuthToken, async (req, response) => {
  try {
    // console.log("updateproduct");
    let finduser = await User.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(req.body.userId),
        },
      },
    ]);
    // console.log(finduser.length);
    if (finduser && finduser.length > 0) {
      let allproducts = await Product.aggregate([
        {
          $match: {
            userId: new mongoose.Types.ObjectId(req.body.userId),
          },
        },
      ]);
      // console.log(allproducts);
      response
        .status(200)
        .send({ msg: "Product fetched Successfully", data: allproducts });
    } else {
      response.status(200).send({ msg: "Invalid User ID" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

// ******************API's not used in web app***********

//get filter products
router.put("/getbylocation", async (req, response) => {
  try {
    // console.log("filter-location-products");
    const location = req.body.location;
    let allproducts = await Product.find({ location });
    // console.log(allproducts.length);
    response
      .status(200)
      .send({ msg: "Product fetched Successfully", data: allproducts });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get filter products
router.put("/getbyavailstatus", async (req, response) => {
  try {
    // console.log("filter-avail-products");
    const availStatus = req.body.avail;
    let allproducts = await Product.find({ availStatus });
    // console.log(allproducts.length);
    response
      .status(200)
      .send({ msg: "Product fetched Successfully", data: allproducts });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get products details limited
router.get("/getAllProductLimitedDetails", async (request, response) => {
  try {
    await Product.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(request.query.id),
        },
      },
      // {
      //   $lookup: {
      //     from: "t_users",
      //     localField: "userId",
      //     foreignField: "_id",
      //     as: "sellerDetails",
      //   },
      // },
      {
        $project: {
          _id: 1,
          productName: 1,
          basePrice: 1,
          quantityPerLot: 1,
          quantityUnit: 1,
          minNoLot: 1,
          // productDesc: 1,
          productImages: 1,
          // producedDate: 1,
          // availableFrom: 1,
          // reviews: 1,
          // ratings: 1,
          // ratedUser: 1,
          // location: 1,
          availStatus: 1,
          // "sellerDetails._id": 1,
          // "sellerDetails.userName": 1,
          // "sellerDetails.mobile": 1,
          // "sellerDetails.city": 1,
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

//get listed items
router.get("/getListedItems", async (req, res) => {
  try {
    var listedProducts = await Product.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(req.query.userId),
        },
      },
      {
        $project: {
          _id: 1,
          productName: 1,
          basePrice: 1,
          quantityUnit: 1,
          minNoLot: 1,
          quantityPerLot: 1,
          productImages: 1,
          availStatus: 1,
          openOrders: 1,
        },
      },
    ]);
    // var openOrders = await Order.aggregate([
    //   {
    //     $match: {
    //       productId: new mongoose.Types.ObjectId(request.query.productId),
    //       isOrderAccepted: true,
    //     },
    //   },
    //   {
    //     $count: "openOrders",
    //   },
    // ]);

    if (listedProducts.length > 0) {
      res.status(200).send({
        message: "Listed products recieved",
        listedProducts: listedProducts,
      });
    } else {
      res.status(200).send({
        message: "No listed items",
      });
    }
  } catch (error) {
    // console.log(error);
    res.status(500).send(error);
  }
});

//get open orders for a specific item
router.get("/getOpenOrders", async (request, response) => {
  try {
    await Order.aggregate([
      {
        $match: {
          productId: new mongoose.Types.ObjectId(request.query.productId),
          isOrderAccepted: true,
        },
      },
      // {
      //   $lookup: {
      //     from: "t_products",
      //     localField: "_id",
      //     foreignField: "userId",
      //     as: "productDetails",
      //   },
      // },
      // {
      //   $project: {
      //     _id: 1,
      //     userName: 1,
      //     city: 1,
      //     "productDetails._id": 1,
      //     "productDetails.productName": 1,
      //     "productDetails.basePrice": 1,
      //     "productDetails.quantityUnit": 1,
      //     "productDetails.productImages": 1,
      //   },
      // },
      {
        $count: "openOrders",
      },
    ]).then((ordersCount) => {
      response.status(200).send({
        message: "orders count found",
        ordersCount: ordersCount,
      });
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

// ******************API's not used in web app***********


//get full product details
router.get("/getProductDetails",verifyAuthToken, async (request, response) => {
  try {
    await Product.aggregate([
      {
        $match: {
          _id: new mongoose.Types.ObjectId(request.query.productId),
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
        },
      },
    ]).then((product) => {
      if (product.length > 0) {
        response
          .status(200)
          .send({ message: "Product details found", productDetails: product });
      } else {
        response.status(200).send({ message: "No product details found" });
      }
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

//get latest products by limit
router.get("/getProductsLimit",verifyAuthToken, async (request, response) => {
  try {
    var limit = Number(request.query.noOfProd);
    if (limit == 0) {
      // console.log("limit: 0");
      Product.aggregate([
        {
          $match: {
            userId: new mongoose.Types.ObjectId(request.query.userId),
            availStatus: true,
          },
        },
        {
          $lookup: {
            from: "t_users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $project: {
            _id: 1,
            quantityPerLot: 1,
            producedDate: 1,
            quantityUnit: 1,
            productName: 1,
            productImages: 1,
            basePrice: 1,
          },
        },
      ]).then((value) => {
        if (value.length != 0) {
          response.status(200).send({
            message: "Products by limit found",
            productsByLimit: value,
          });
        } else {
          response.status(200).send({
            message: "Products not found",
          });
        }
      });
    } else {
      // console.log("limit: " + limit);
      await Product.aggregate([
        {
          $match: {
            userId: new mongoose.Types.ObjectId(request.query.userId),
            availStatus: true,
          },
        },
        {
          $lookup: {
            from: "t_users",
            localField: "userId",
            foreignField: "_id",
            as: "sellerDetails",
          },
        },
        {
          $project: {
            _id: 1,
            quantityPerLot: 1,
            producedDate: 1,
            quantityUnit: 1,
            productName: 1,
            productImages: 1,
            basePrice: 1,
          },
        },
      ])
        .limit(limit)
        .then((value) => {
          if (value.length != 0) {
            response.status(200).send({
              message: "Products by limit found",
              productsByLimit: value,
            });
          } else {
            response.status(200).send({
              message: "Products not found",
            });
          }
        });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});


//get orders history
router.get("/getOrdersHistory",verifyAuthToken, async (req, res) => {
  // console.log("************getOrdersHistory Start************");
  try {

    let orderDetails = [];
    await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: true,
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $lookup: {
          from: "t_products",
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
          "buyerDetails._id": 1,
          "buyerDetails.userName": 1,
          "buyerDetails.mobile": 1,
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
      if(value.length > 0){
        orderDetails = value;
      }
      
    });

    return res.status(200).send({
      message: "Orders history recieved",
      orderDetails: value,
    });

  } catch (error) {
    res.status(500).send(error);
  }
});



// get order details
router.get("/getOrderDetails",verifyAuthToken, async (req, res) => {
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
          from: "t_users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      // {
      //   $lookup: {
      //     from: "t_users",
      //     localField: "buyerId",
      //     foreignField: "_id",
      //     as: "buyerDetails",
      //   },
      // },
      {
        $lookup: {
          from: "t_products",
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
      if(value.length > 0){

        res.status(200).send({
          message: "Orders details recieved",
          orderDetails: value,
        });
      } else{
        res.status(200).send({
          message: "No order details found",
        });
      }
    });
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});



//get active orders for sellers
router.get("/getActiveOrders",verifyAuthToken, async (req, res) => {
  // console.log("************getActiveOrders Start************");
  try {
    await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: true,
          isBuyerClosed: false,
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $lookup: {
          from: "t_products",
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
          "buyerDetails._id": 1,
          "buyerDetails.userName": 1,
          "buyerDetails.mobile": 1,
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

//get pending orders for sellers
router.get("/getPendingOrders",verifyAuthToken,  async (req, res) => {
  // console.log("************getPendingOrders Start************");
  try {
    await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: false,
          isSellerClosed: false,
          isBuyerClosed: false,
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $lookup: {
          from: "t_products",
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
          "buyerDetails._id": 1,
          "buyerDetails.userName": 1,
          "buyerDetails.mobile": 1,
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

//get flagged orders for sellers
router.get("/getFlaggedOrders",verifyAuthToken,  async (req, res) => {
  // console.log("************getFlaggedOrders Start************");
  try {
    await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.id),
          isClosed: false,
          isOrderAccepted: true,
          isSellerClosed: false,
          isBuyerClosed: true,
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "buyerId",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $lookup: {
          from: "t_products",
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
          "buyerDetails._id": 1,
          "buyerDetails.userName": 1,
          "buyerDetails.mobile": 1,
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

//get user review
router.get("/getUserReview",verifyAuthToken,  async (req, res) => {
  try {
    await UserReview.aggregate([
      {
        $match: {
          postedFor: new mongoose.Types.ObjectId(req.query.postedFor),
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "postedBy",
          foreignField: "_id",
          as: "buyerDetails",
        },
      },
      {
        $project: {
          _id: 1,
          review: 1,
          reply: 1,
          createdAt: 1,
          "buyerDetails.userName": 1,
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
    response.status(500).send(error);
  }
});

//reply to a review
router.put("/replyToUserReview",verifyAuthToken, async (req, res) => {
  try {
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

//reject incoming order
router.delete("/rejectOrder",verifyAuthToken, async (request, response) => {
  // console.log("reject orders");
  try {
    const orderDelete = await Order.deleteOne({ _id: request.body.orderId });
    // console.log(orderDelete);
    if (orderDelete) {
      response.status(200).send({ message: "Order rejected successfully" });
    } else {
      response.status(200).send({ message: "Invalid order id" });
    }
  } catch (error) {
    // console.log(error);
    response.status(500).send(error);
  }
});

router.get("/getDashboardStats",verifyAuthToken, async (req, res) => {
  try {
    //no. of products
    let productCount = await Product.countDocuments({
      userId: new mongoose.Types.ObjectId(req.query.userId),
    });

    //total sales
    let totalSales = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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

    //top products sold
    let topProductsSold = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
          isSellerClosed: true,
          isBuyerClosed: true,
          isOrderAccepted: true,
        },
      },
      {
        $lookup: {
          from: "t_products",
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
          from: "t_products",
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
    let recentReceivedOrders = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: false,
          isSellerClosed: false,
          isBuyerClosed: false,
          isOrderAccepted: false,
        },
      },
      // {
      //   $lookup: {
      //     from: "t_products",
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
          from: "t_products",
          localField: "productId",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      {
        $lookup: {
          from: "t_users",
          localField: "buyerId",
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
          isClosed: true,
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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

    let flagWaitingBuyerApprovalOrders = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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

    let flagedOrders = await Order.aggregate([
      {
        $match: {
          sellerId: new mongoose.Types.ObjectId(req.query.userId),
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

    // console.log(
    //   totalOrders,
    //   completedOrders,
    //   rejectedOrders,
    //   productCount,
    //   pendingOrders,
    //   activeOrders,
    //   flagWaitingBuyerApprovalOrders,
    //   flagedOrders
    // );
    // if (totalOrders && productCount) {
    res.status(200).send({
      message: "Dashboard stats received",
      data: {
        productCount: productCount,
        totalSales: totalSales,
        acceptedOrders: acceptedOrders,
        topProductsSold: topProductsSold,
        recentReceivedOrders: recentReceivedOrders,
        totalOrders: totalOrders,
        completedOrders: completedOrders,
        rejectedOrders: rejectedOrders,
        pendingOrders: pendingOrders,
        activeOrders: activeOrders,
        flagWaitingBuyerApprovalOrders: flagWaitingBuyerApprovalOrders,
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
