const express = require('express');
const router = express.Router();
const Attendance = require('../models/attendance');

// ✅ POST /api/attendance → Mark attendance (with duplicate prevention)
router.post('/', async (req, res) => {
  try {
    const data = req.body; // Array of attendance records
    const filteredData = [];

    for (const entry of data) {
      const { roll, subject, date, semester, section } = entry;

      // ❌ Skip if already exists
      const exists = await Attendance.findOne({ roll, subject, date, semester, section });
      if (!exists) {
        filteredData.push(entry);
      }
    }

    if (filteredData.length === 0) {
      return res.status(409).json({ message: 'Attendance already submitted for all entries' });
    }

    // ✅ Insert only unique entries
    await Attendance.insertMany(filteredData);
    res.status(201).json({ message: '✅ Attendance recorded successfully' });
  } catch (error) {
    console.error('❌ Attendance submission error:', error);
    res.status(500).json({
      error: 'Server error while submitting attendance',
      details: error.message,
    });
  }
});

// ✅ GET /api/attendance?roll=20 → Get all attendance for a student
router.get('/', async (req, res) => {
  const { roll } = req.query;

  if (!roll) {
    return res.status(400).json({ error: 'Roll number is required' });
  }

  try {
    const records = await Attendance.find({ roll }).sort({ date: -1 });
    res.status(200).json(records);
  } catch (error) {
    console.error('❌ Attendance fetch error:', error);
    res.status(500).json({
      error: 'Failed to fetch attendance',
      details: error.message,
    });
  }
});

module.exports = router;
