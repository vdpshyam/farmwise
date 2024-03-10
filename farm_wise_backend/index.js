#!/usr/bin/env nodejs
const express = require("express");
const app = express();
var cors = require("cors");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
dotenv.config();

app.use(cors());
app.all("*", function (req, res, next) {
  /**
   * Response settings
   * @type {Object}
   */
  var responseSettings = {
    AccessControlAllowOrigin: req.headers.origin,
    AccessControlAllowHeaders:
      "Content-Type,X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5,  Date, X-Api-Version, X-File-Name",
    AccessControlAllowMethods: "POST, GET, PUT, DELETE, OPTIONS",
    AccessControlAllowCredentials: true,
  };

  /**
   * Headers
   */
  res.header(
    "Access-Control-Allow-Credentials",
    responseSettings.AccessControlAllowCredentials
  );
  res.header(
    "Access-Control-Allow-Origin",
    responseSettings.AccessControlAllowOrigin
  );
  res.header(
    "Access-Control-Allow-Headers",
    req.headers["access-control-request-headers"]
      ? req.headers["access-control-request-headers"]
      : "x-requested-with"
  );
  res.header(
    "Access-Control-Allow-Methods",
    req.headers["access-control-request-method"]
      ? req.headers["access-control-request-method"]
      : responseSettings.AccessControlAllowMethods
  );

  if ("OPTIONS" == req.method) {
    res.send(200);
  } else {
    next();
  }
});
app.listen(process.env.PORT, function () {
  console.log(
    "Server Started now listening for requests at http://localhost:3001/"
  );
});

const connectionParams = {
  dbName: 'farmwisedev',
  useNewUrlParser: true,
  useUnifiedTopology: true,
};
const uri = process.env.MONGOURL;

mongoose
  .connect(uri, connectionParams)
  .then(() => {
    console.log("Connected to database ");
  })
  .catch((err) => {
    console.error(`Error connecting to the database. \n${err}`);
  });

mongoose.Promise = global.Promise;

app.use(express.static("public"));

app.use(express.json());

app.use("/api/common", require("./routes/Rindex"));
app.use("/api/farmer", require("./routes/Findex"));
app.use("/api/admin", require("./routes/admin"));