const express = require('express');
const authRouter = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const auth = require('../middleware/auth');

// ✅ Sign Up Route
authRouter.post("/signup", async (req, res) => {
    try {
        const { name, roll, email, phone, password, section, semester } = req.body;

        const existingUser = await User.findOne({ roll });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 9);

        let user = new User({
            name,
            roll,
            email,
            phone,
            password: hashedPassword,
            section,
            semester,
        });

        user = await user.save();
        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// ✅ Sign In Route
authRouter.post("/signin", async (req, res) => {
    try {
        const { roll, password } = req.body;

        const user = await User.findOne({ roll });
        if (!user) {
            return res.status(400).json({ message: "User not found" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "Invalid Password" });
        }

        const token = jwt.sign({ id: user._id }, "passwordKey");
        res.json({ token, ...user._doc });
    } catch (e) {
        console.error("Login error:", e);
        res.status(500).json({ error: e.message });
    }
});

// ✅ Token Validation
authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        const token = req.header("x-auth-token");
        if (!token) return res.json(false);

        const verified = jwt.verify(token, "passwordKey");
        if (!verified) return res.json(false);

        const user = await User.findById(verified.id);
        if (!user) return res.json(false);

        res.json(true);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// ✅ Get User Data (protected)
authRouter.get("/", auth, async (req, res) => {
    const user = await User.findById(req.user);
    res.json({ ...user._doc, token: req.token });
});

// ✅ Get all students
authRouter.get("/students", async (req, res) => {
    try {
        const students = await User.find({});
        res.json(students);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = authRouter;
