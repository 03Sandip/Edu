const mongoose = require('mongoose');

const librarySchema = new mongoose.Schema({
  title: { type: String, required: true },
  type: { type: String, enum: ['Book', 'Research Paper'], required: true },
  fileUrl: { type: String, required: true },
  uploadedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Library', librarySchema);
