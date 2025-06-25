const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const router = express.Router();
const Library = require('../models/library');

// 📁 Setup multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/library';
    fs.mkdirSync(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});
const upload = multer({ storage });

/**
 * 📤 POST /api/library → Upload a new book or paper
 * Body: title, type (Book/Research Paper), description (optional), file (pdf)
 */
router.post('/', upload.single('file'), async (req, res) => {
  try {
    const { title, type, description } = req.body;
    const file = req.file;

    if (!file || !title || !type) {
      return res.status(400).json({ error: 'Title, type and PDF file are required' });
    }

    const newEntry = new Library({
      title,
      type,
      description,
      fileUrl: `/uploads/library/${file.filename}`  // ✅ Corrected path
    });

    await newEntry.save();
    res.status(201).json({ message: 'Upload successful', data: newEntry });
  } catch (err) {
    res.status(500).json({ error: 'Upload failed', details: err.message });
  }
});

/**
 * 📚 GET /api/library → Get all library items
 */
router.get('/', async (req, res) => {
  try {
    const all = await Library.find().sort({ createdAt: -1 });
    res.status(200).json(all);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch', details: err.message });
  }
});

/**
 * ✏️ PUT /api/library/:id → Update title/type/description
 */
router.put('/:id', async (req, res) => {
  try {
    const { title, description, type } = req.body;
    const updated = await Library.findByIdAndUpdate(
      req.params.id,
      { title, description, type },
      { new: true }
    );
    res.status(200).json({ message: 'Updated successfully', data: updated });
  } catch (err) {
    res.status(500).json({ error: 'Update failed', details: err.message });
  }
});

/**
 * 🗑 DELETE /api/library/:id → Delete an entry and its file
 */
router.delete('/:id', async (req, res) => {
  try {
    const doc = await Library.findById(req.params.id);
    if (!doc) return res.status(404).json({ error: 'Not found' });

    // ✅ Delete file from disk
    const filePath = path.join(__dirname, '..', 'uploads/library', path.basename(doc.fileUrl));
    fs.unlink(filePath, (err) => {
      if (err) console.warn('⚠️ File not found or already deleted:', filePath);
    });

    await doc.deleteOne();
    res.status(200).json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Delete failed', details: err.message });
  }
});

module.exports = router;
