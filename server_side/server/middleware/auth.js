const jwt = require('jsonwebtoken');


const auth = async (req, res, next) => {
 try {
    const token = req.header("x-auth-token");
    if (!token) {
        return res.status(401).json({ message: "No authentication token, authorization denied" });
    }
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) {
        return res.
        status(401).
        json({ message: "Token verification failed, authorization denied" });
    }
    req.user = verified.id; // Store user ID in request object
    req.token = token; // Store token in request object
    next(); // Call the next middleware or route handler
 } catch (error) {
    res.status(500).json({ error: error.message });
    

 }
};
module.exports = auth;