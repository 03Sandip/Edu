const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
  semester: String,
  section: String,
  subject: String,
  fileUrl: String,
  uploadDate: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Assignment', assignmentSchema);
