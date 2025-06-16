const express = require('express');
const User = require('../models/user'); // use your existing user model

const studentRouter = express.Router();

// ✅ Get all students with optional filters
studentRouter.get('/students', async (req, res) => {
  try {
    const { semester, section } = req.query;

    // Build filter object from query
    const filter = {};
    if (semester) filter.semester = semester;
    if (section) filter.section = section;

    console.log("Fetching students with filter:", filter); // Optional: debug log

    const students = await User.find(filter).select('-password');
    res.json(students);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch students' });
  }
});

// ✅ Get total student count
studentRouter.get('/student-count', async (req, res) => {
  try {
    const count = await User.countDocuments();
    res.json({ count }); // 👈 key is "count" to match Flutter
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch student count' });
  }
});

// ✅ Get single student by ID
studentRouter.get('/students/:id', async (req, res) => {
  try {
    const student = await User.findById(req.params.id).select('-password');
    if (!student) return res.status(404).json({ message: 'Student not found' });
    res.json(student);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch student' });
  }
});

// ✅ Update student
studentRouter.put('/students/:id', async (req, res) => {
  try {
    const updated = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    ).select('-password');
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update student' });
  }
});

// ✅ Delete student
studentRouter.delete('/students/:id', async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'Student deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete student' });
  }
});


module.exports = studentRouter;
