const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

// ✅ Route Imports
const authRouter = require('./routers/auth');
const studentRouter = require('./routers/student');
const assignSubjectRouter = require('./routers/assignSubjects');
const noteRouter = require('./routers/notes');
const attendanceRouter = require('./routers/attendance');
const assignmentRouter = require('./routers/assignments'); // ✅ NEW: Assignment router

const PORT = process.env.PORT || 3000;
const app = express();

// ✅ Middleware
app.use(cors());
app.use(express.json());

// ✅ Serve static files
app.use('/uploads/notes', express.static(path.join(__dirname, 'uploads/notes')));
app.use('/uploads/assignments', express.static(path.join(__dirname, 'uploads/assignments'))); // ✅ Serve uploaded assignments

// ✅ API Routes
app.use('/api', authRouter);
app.use('/api', studentRouter);
app.use('/api', assignSubjectRouter);
app.use('/api/notes', noteRouter);
app.use('/api/attendance', attendanceRouter);
app.use('/api/assignments', assignmentRouter); // ✅ Assignments route

// ✅ MongoDB Connection
const DB = "mongodb+srv://sandip:OBmR4DOL3yMWJfGM@cluster0.vyuyuvf.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongoose.connect(DB)
  .then(() => console.log("✅ MongoDB connected successfully"))
  .catch((error) => console.error("❌ MongoDB connection error:", error));

// ✅ Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});
