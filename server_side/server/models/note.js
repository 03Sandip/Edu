// models/Note.js
const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  semester: {
    type: String,
    required: true
  },
  subject: {
    type: String,
    required: true
  },
  filePath: {
    type: String,
    required: true
  },
  uploadedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Note', noteSchema);
