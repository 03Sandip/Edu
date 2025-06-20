const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Marksheet = require('../models/marksheet');
const User = require('../models/user');

// 📁 Ensure upload folder exists
const uploadDir = path.join(__dirname, '..', 'uploads', 'marksheets');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 🔧 Multer config for local file storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// ✅ Route: Upload marksheet file
router.post('/marksheet/upload', upload.single('file'), async (req, res) => {
  const { roll, semester, section } = req.body;

  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  try {
    const student = await User.findOne({ roll, semester, section });
    if (!student) {
      return res.status(404).json({ error: 'Student not found' });
    }

    const existing = await Marksheet.findOne({ roll, semester, section });
    if (existing) {
      return res.status(409).json({ error: 'Marksheet already exists for this student' });
    }

    const fileUrl = `/uploads/marksheets/${req.file.filename}`;

    const newMarksheet = new Marksheet({
      roll,
      semester,
      section,
      fileUrl,
    });

    await newMarksheet.save();

    res.status(201).json({
      message: 'Marksheet uploaded successfully',
      fileUrl,
      data: newMarksheet,
    });
  } catch (error) {
    console.error('Error uploading marksheet:', error);
    res.status(500).json({ error: 'Failed to upload marksheet' });
  }
});

// ✅ Route: Update marksheet
router.put('/marksheet/update', upload.single('file'), async (req, res) => {
  const { roll, semester, section } = req.body;
  try {
    const student = await User.findOne({ roll, semester, section });
    if (!student) {
      return res.status(404).json({ error: 'Student not found' });
    }

    const existing = await Marksheet.findOne({ roll, semester, section });
    if (!existing) {
      return res.status(404).json({ error: 'Marksheet not found to update' });
    }

    const fullPath = path.join(__dirname, '..', existing.fileUrl);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }

    const newFileUrl = `/uploads/marksheets/${req.file.filename}`;
    existing.fileUrl = newFileUrl;
    await existing.save();

    res.status(200).json({
      message: 'Marksheet updated successfully',
      fileUrl: newFileUrl,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update marksheet' });
  }
});

// ✅ Route: Get marksheet list
router.get('/marksheet/list', async (req, res) => {
  const { semester, section } = req.query;

  try {
    const result = await Marksheet.find({ semester, section });
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch marksheets' });
  }
});

// ✅ Route: Check if marksheet already exists
router.get('/marksheet/check', async (req, res) => {
  const { roll, semester, section } = req.query;

  try {
    const existing = await Marksheet.findOne({ roll, semester, section });
    res.status(200).json({ exists: !!existing });
  } catch (error) {
    res.status(500).json({ error: 'Failed to check marksheet' });
  }
});

// ✅ Route: Delete marksheet
router.delete('/marksheet/delete', async (req, res) => {
  const { roll, semester, section } = req.query;

  try {
    const result = await Marksheet.findOneAndDelete({ roll, semester, section });
    if (!result) {
      return res.status(404).json({ error: 'Marksheet not found' });
    }

    const fullPath = path.join(__dirname, '..', result.fileUrl);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }

    res.status(200).json({ message: 'Marksheet deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete marksheet' });
  }
});

// ✅ Route: Get student name
router.get('/students/name', async (req, res) => {
  const { roll, semester, section } = req.query;
  console.log('Getting name for:', { roll, semester, section });
  try {
    const student = await User.findOne({ roll, semester, section });
    if (!student) return res.status(404).json({ error: 'Student not found' });
    res.status(200).json({ name: student.name });
  } catch (error) {
    console.error('Failed to fetch student name:', error);
    res.status(500).json({ error: 'Failed to fetch student name' });
  }
});

// ✅ Route: Get roll numbers for given sem & section
router.get('/students/rolls', async (req, res) => {
  const { semester, section } = req.query;

  if (!semester || !section) {
    return res.status(400).json({ error: 'Semester and section are required' });
  }

  try {
    console.log('Fetching rolls for:', semester, section);
    const students = await User.find({ semester, section }, 'roll');
    const rolls = students.map(s => s.roll);
    res.status(200).json(rolls);
  } catch (error) {
    console.error('Failed to fetch student rolls:', error);
    res.status(500).json({ error: 'Failed to fetch student rolls' });
  }
});

// ✅ Route: Get all students by semester and section
router.get('/students/by-sem-sec', async (req, res) => {
  const { semester, section } = req.query;

  if (!semester || !section) {
    return res.status(400).json({ error: 'Semester and section are required' });
  }

  try {
    console.log('Fetching students for:', semester, section);
    const students = await User.find({ semester, section }).select('-password');
    res.status(200).json(students);
  } catch (error) {
    console.error('Failed to fetch student list:', error);
    res.status(500).json({ error: 'Failed to fetch student list' });
  }
});

module.exports = router;