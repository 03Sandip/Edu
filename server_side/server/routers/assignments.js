const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Assignment = require('../models/assignment');

const router = express.Router();

// ✅ Ensure uploads/assignments directory exists
const assignmentsDir = path.join(__dirname, '../uploads/assignments');
if (!fs.existsSync(assignmentsDir)) {
  fs.mkdirSync(assignmentsDir, { recursive: true });
}

// ✅ Configure multer for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, assignmentsDir); // use correct variable name
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

/**
 * ✅ POST /api/assignments/upload
 * Upload a new assignment
 */
router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    const { semester, section, subject } = req.body;

    if (!semester || !section || !subject || !req.file) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const fileUrl = `/uploads/assignments/${req.file.filename}`;

    const assignment = new Assignment({ semester, section, subject, fileUrl });
    await assignment.save();

    res.status(200).json({ message: 'Assignment uploaded successfully', data: assignment });
  } catch (error) {
    console.error('❌ Upload error:', error);
    res.status(500).json({ error: 'Failed to upload assignment' });
  }
});

/**
 * ✅ GET /api/assignments
 * Get all or filtered assignments
 */
router.get('/', async (req, res) => {
  try {
    const { semester, section, subject } = req.query;

    const filter = {};
    if (semester) filter.semester = semester;
    if (section) filter.section = section;
    if (subject) filter.subject = subject; // ✅ Add subject to filter

    const assignments = await Assignment.find(filter).sort({ uploadDate: -1 });
    res.json(assignments);
  } catch (err) {
    console.error('❌ Fetch error:', err);
    res.status(500).json({ error: 'Error fetching assignments' });
  }
});

/**
 * ✅ DELETE /api/assignments/:id
 * Delete an assignment by ID (and remove the file too)
 */
router.delete('/:id', async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id);
    if (!assignment) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    const filePath = path.join(__dirname, '..', assignment.fileUrl);
    fs.unlink(filePath, (err) => {
      if (err) {
        console.error('⚠️ File deletion error:', err);
      }
    });

    await Assignment.findByIdAndDelete(req.params.id);

    res.json({ message: 'Assignment deleted successfully' });
  } catch (err) {
    console.error('❌ Delete error:', err);
    res.status(500).json({ error: 'Failed to delete assignment' });
  }
});

module.exports = router;
