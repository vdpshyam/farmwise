const jwt = require('jsonwebtoken');
const config = process.env;

const verifyAuthToken = (req, res, next) => {
  const token = req.body.token || req.query.token || req.headers["authorization"];

  if (!token) {
    return res.status(403).send({message:"A token is required for authentication"});
  }

  try {
    const decoded = jwt.verify(token,process.env.TOKEN_SECRET);
    req.user = decoded;
    // console.log("decoded");
  } catch (err) {
    return res.status(401).send({message:"Invalid Token"});
  }
  return next();
};

module.exports = verifyAuthToken;