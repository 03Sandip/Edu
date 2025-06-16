const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  roll: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  section: { type: String, required: true }, // e.g., "CSE-1"
  semester: { type: String, required: true }, // e.g., "1st"
  
  // ✅ NEW FIELD
  subjects: {
    type: [String], // List of subject names
    default: []
  }

}, { timestamps: true });

const User = mongoose.model("User", userSchema);
module.exports = User;
