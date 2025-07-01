const express = require('express');
const router = express.Router();
const Fee = require('../models/fees');

/// ✅ GET: Check payment status by roll number and semester
router.get('/paidstatus', async (req, res) => {
  const { rollNumber, semester } = req.query;

  if (!rollNumber || !semester) {
    return res.status(400).json({ message: 'rollNumber and semester are required.' });
  }

  try {
    const fee = await Fee.findOne({ rollNumber, semester });

    if (!fee || fee.status !== 'Paid') {
      return res.status(404).json({ message: 'No paid fee found for this semester.' });
    }

    return res.status(200).json({
      rollNumber: fee.rollNumber,
      semester: fee.semester,
      amount: fee.amount,
      status: fee.status,
      paidDate: fee.paidDate,
    });
  } catch (err) {
    console.error('❌ Error checking payment status:', err);
    return res.status(500).json({ error: 'Server error while checking payment status.' });
  }
});

// ✅ POST: Update fee status when student makes payment (one-time only)
router.post('/updatestatus', async (req, res) => {
  try {
    const { rollNumber, semester, amount } = req.body;

    if (!rollNumber || !semester || !amount) {
      return res.status(400).json({ message: 'rollNumber, semester, and amount are required.' });
    }

    // 🔍 Check if already paid
    const existingFee = await Fee.findOne({ rollNumber, semester });

    if (existingFee && existingFee.status === 'Paid') {
      return res.status(400).json({ message: 'Fee already paid for this semester.' });
    }

    // ✅ Update or insert fee record
    const updatedFee = await Fee.findOneAndUpdate(
      { rollNumber, semester },
      {
        $set: {
          amount,
          status: 'Paid',
          paidDate: new Date(),
        },
      },
      { upsert: true, new: true }
    );

    return res.status(200).json({
      message: '✅ Fee marked as paid.',
      data: updatedFee,
    });

  } catch (err) {
    console.error('❌ Fee update error:', err);
    res.status(500).json({ error: 'Server error while updating fee status.' });
  }
});

module.exports = router;
