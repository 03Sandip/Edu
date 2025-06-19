const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Note = require('../models/note');

// Ensure upload directory exists
const uploadPath = path.join(__dirname, '../uploads/notes');
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

// Multer config
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  },
});

const upload = multer({ storage });

// POST /api/notes - Upload a new note
router.post('/', upload.single('noteFile'), async (req, res) => {
  try {
    const { subject, semester } = req.body;
    const noteFile = req.file;

    if (!subject || !semester || !noteFile) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const newNote = new Note({
      subject,
      semester,
      filePath: `/uploads/notes/${noteFile.filename}`,
      uploadedAt: new Date(),
    });

    await newNote.save();
    res.status(201).json({ message: 'Note uploaded successfully', note: newNote });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/notes?semester=5th&subject=Operating Systems
router.get('/', async (req, res) => {
  const { semester, subject } = req.query;
  try {
    const filter = {};
    if (semester) filter.semester = semester;
    if (subject) filter.subject = subject;

    const notes = await Note.find(filter).sort({ uploadedAt: -1 });
    res.json({ notes });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// DELETE /api/notes/:id - Delete a note
router.delete('/:id', async (req, res) => {
  const noteId = req.params.id;
  try {
    const note = await Note.findById(noteId);
    if (!note) {
      return res.status(404).json({ message: 'Note not found' });
    }

    // Delete file from disk
    const absolutePath = path.join(__dirname, '..', note.filePath);
    if (fs.existsSync(absolutePath)) {
      fs.unlinkSync(absolutePath);
    }

    await Note.findByIdAndDelete(noteId);
    res.status(200).json({ message: 'Note deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
