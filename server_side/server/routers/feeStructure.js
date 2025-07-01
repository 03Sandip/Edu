const express = require('express');
const router = express.Router();
const FeeStructure = require('../models/feeStructure');

// Get all fee structures
router.get('/', async (req, res) => {
  try {
    const { semester } = req.query;
    let query = {};
    if (semester) query.semester = semester;

    const fees = await FeeStructure.find(query);
    res.json(fees);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create or update fee structure for a semester
router.post('/', async (req, res) => {
  try {
    const { semester, amount } = req.body;
    const updated = await FeeStructure.findOneAndUpdate(
      { semester },
      { amount },
      { upsert: true, new: true }
    );
    res.status(200).json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
