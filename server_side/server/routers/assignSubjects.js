const express = require('express');
const router = express.Router();
const User = require('../models/user');
const SemesterSubject = require('../models/semesterSubject');

// ✅ POST /api/assign-subjects
router.post('/assign-subjects', async (req, res) => {
  const { semester, subjects } = req.body;

  if (!semester || !Array.isArray(subjects) || subjects.length === 0) {
    return res.status(400).json({ error: 'Semester and subjects are required.' });
  }

  try {
    // Save or update semester's subject list
    await SemesterSubject.findOneAndUpdate(
      { semester },
      { subjects },
      { upsert: true, new: true }
    );

    // Assign subjects to all users in that semester
    await User.updateMany(
      { semester },
      { $set: { subjects } }
    );

    res.status(200).json({ message: `Subjects assigned to ${semester} semester users.` });
  } catch (err) {
    console.error('Subject assignment error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ GET /api/assign-subjects?semester=1st
router.get('/assign-subjects', async (req, res) => {
  const { semester } = req.query;

  if (!semester) {
    return res.status(400).json({ error: 'Semester query parameter is required.' });
  }

  try {
    const data = await SemesterSubject.findOne({ semester });

    if (!data) {
      return res.status(404).json({ error: 'No subjects found for this semester.' });
    }

    res.status(200).json(data);
  } catch (err) {
    console.error('Error fetching subjects:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
