const mongoose = require('mongoose');

const feeSchema = new mongoose.Schema({
  rollNumber: { type: String, required: true },
  semester: { type: String, required: true }, // ✅ Added this
  amount: { type: Number, required: true },
  status: { type: String, enum: ['Paid', 'Unpaid'], default: 'Unpaid' },
  paidDate: { type: Date, default: null }
});

// ✅ Optional: Add compound index to prevent duplicate roll+semester records
feeSchema.index({ rollNumber: 1, semester: 1 }, { unique: true });

module.exports = mongoose.model('Fee', feeSchema);
