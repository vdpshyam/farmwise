const dotenv = require("dotenv");
const verifyAuthToken = require("../middleware/verifyAuthToken");

const User = require("../model/user");
const Order = require("../model/order");
const SubscriptionDetail = require("../model/subscriptionDetails");

dotenv.config();

var moment = require("moment");

const router = require("express").Router({
  caseSensitive: true,
});

router.get("/commonalive", (req, res) => {
  // console.log("alive called");
  res.status(200).send({ status: "alive" });
});

router.get("/getalluser",verifyAuthToken, async (req, res) => {
    try {
      // console.log("*****");
      // console.log("getUserDetails");
      // console.log("*****");
      let user = await User.aggregate([
        {
            $match: {
                userType: { $in: ['Farmer', 'Wholesaler'] }, // Filter users with roles 'buyer' or 'seller'
            },
          },
        {
          $project: {
            _id: 1, 
            userName: 1,
            email: 1,
            mobile:1,
            userType:1,
            locality: 1,
            city: 1,
            state:1,
            pincode:1,
            verifiedProfile:1,
            avatarUrl:1,
            createdAt:1
          },
        },
        {
            $sort: {
              createdAt: -1, // Sort in descending order based on createdAt
            },
        },
      ]);
      if (user) {
        // console.log(user.length);
        res.status(200).send({ message: "success", userDetails: user });
      } else {
        res.status(200).send({ message: "Users not found" });
      }
    } catch (error) {
      // console.log(error);
      res.status(500).send(error);
    }
});

router.get("/getdashstats",verifyAuthToken, async (req, res) => {
    try {
      // console.log("*****");
      // console.log("getUserDetails");
      // console.log("*****");

      let userstats = await User.aggregate([
        {
            $match: {
                userType: { $in: ['Farmer', 'Wholesaler'] }, // Filter users with roles 'buyer' or 'seller'
            },
          },
        {
        $group: {
            _id: '$userType', // Group by role field
            count: { $sum: 1 }, // Count the documents within each group
        },
        },
        {
            $project: {
            _id: 0,
            role: '$_id',
            count: 1,
            },
        },
      ]);

      let totalBuyValue = await Order.aggregate([
        {
          $match: {            
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

      let totalOrders = await Order.aggregate([        
        {
          $group: {
            _id: null,
            totalCount: { $sum: 1 },
          },
        },
      ]);

      let totalSubscription = await SubscriptionDetail.aggregate([       
        {
          $group: {
            _id: null,
            totalAmount: { $sum: "$creditAmount" },
            totalCount: { $sum: 1 },
          },
        },
      ]);


      let orderWise = await Order.aggregate([
        // {
        //     $match: {            
        //       isClosed: true,
        //       isSellerClosed: true,
        //       isBuyerClosed: true,
        //       isOrderAccepted: true,
        //     },
        // },
        {
          $group: {
            _id: {
              year: { $year: '$createdAt' },
              month: { $month: '$createdAt' },
            },
            count: { $sum: 1 },
          },
        },
        {
          $project: {
            _id: 0,
            year: '$_id.year',
            month: '$_id.month',
            count: 1,
          },
        },
        {
          $sort: {
            year: -1,
            month: -1,
          },
        },
      ]);

      let totalSalesWise = await Order.aggregate([
        {
          $match: {            
            isClosed: true,
            isSellerClosed: true,
            isBuyerClosed: true,
            isOrderAccepted: true,
          },
        },
        {
            $group: {
              _id: {
                year: { $year: '$createdAt' },
                month: { $month: '$createdAt' },
              },
              totalSales: { $sum: "$orderValue" },
            },
          },
          {
            $project: {
              _id: 0,
              year: '$_id.year',
              month: '$_id.month',
              totalSales: 1,
            },
          },
          {
            $sort: {
              year: -1,
              month: -1,
            },
          },
      ]);


      if (userstats) {
        // console.log(userstats,totalOrders,totalBuyValue);
        res.status(200).send({ 
            message: "success", 
            statsData:{
            userstats: userstats,
            sales:totalBuyValue,
            orders:totalOrders,
            subscription:totalSubscription,
            orderwised:orderWise,
            saleswise:totalSalesWise
            }
        });
      } else {
        res.status(200).send({ message: "Users not found" });
      }
    } catch (error) {
      // console.log(error);
      res.status(500).send(error);
    }
});



module.exports = router;