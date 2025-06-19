const express = require('express');
const Notification = require('../models/notification');
const router = express.Router();

// ✅ Create Notification (supports target: all, semester, section, roll)
router.post('/notifications', async (req, res) => {
  try {
    const { title, message, target, targetValue } = req.body;

    const notification = {
      title,
      message,
      targetSemester: null,
      targetSection: null,
      targetUserId: null,
    };

    // Dynamically set target field
    if (target === 'semester') {
      notification.targetSemester = targetValue;
    } else if (target === 'section') {
      notification.targetSection = targetValue;
    } else if (target === 'roll') {
      notification.targetUserId = targetValue;
    }

    const saved = await Notification.create(notification);
    res.status(201).json(saved);
  } catch (err) {
    console.error("Notification error:", err);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// ✅ Get Notifications (Student filter)
router.get('/notifications', async (req, res) => {
  try {
    const { semester, section, userId } = req.query;

    const filter = {
      $or: [
        { targetSemester: semester, targetSection: section },
        { targetUserId: userId },
        { targetSemester: null, targetSection: null, targetUserId: null }, // for all
      ],
    };

    const notifications = await Notification.find(filter).sort({ createdAt: -1 });
    res.status(200).json(notifications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// ✅ Update Notification
router.put('/notifications/:id', async (req, res) => {
  try {
    const { title, message, receivers } = req.body;
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { title, message, receivers },
      { new: true }
    );
    if (!notification) return res.status(404).json({ error: "Notification not found" });
    res.json(notification);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update notification' });
  }
});

// ✅ Delete Notification
router.delete('/notifications/:id', async (req, res) => {
  try {
    const deleted = await Notification.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: "Notification not found" });
    res.json({ message: "Notification deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});

module.exports = router;
