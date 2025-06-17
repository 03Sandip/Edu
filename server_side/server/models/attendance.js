const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  roll: { type: String, required: true },
  subject: { type: String, required: true },
  semester: { type: String, required: true },
  section: { type: String, required: true },
  date: {
    type: String,
    default: () => new Date().toISOString().split('T')[0] // "YYYY-MM-DD"
  },
  status: { type: String, enum: ['Present', 'Absent'], required: true }
}, { timestamps: true });

attendanceSchema.index({ roll: 1, subject: 1, date: 1 }, { unique: true }); // Prevent duplicates

module.exports = mongoose.model('Attendance', attendanceSchema);
