const mongoose = require('mongoose');

const FeeStructureSchema = new mongoose.Schema({
  semester: { type: String, required: true, unique: true },
  amount: { type: Number, required: true }
});

module.exports = mongoose.model('FeeStructure', FeeStructureSchema);
