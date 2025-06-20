const mongoose = require('mongoose');

const marksheetSchema = new mongoose.Schema({
  roll: String,
  semester: String,
  section: String,
  fileUrl: String,
  uploadedAt: {
    type: Date,
    default: Date.now,
  }
});

module.exports = mongoose.model('Marksheet', marksheetSchema);
