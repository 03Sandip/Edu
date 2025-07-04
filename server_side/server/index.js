require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Middleware
app.use(cors());
app.use(express.json());

// ✅ Serve static files
app.use('/uploads/notes', express.static(path.join(__dirname, 'uploads/notes')));
app.use('/uploads/assignments', express.static(path.join(__dirname, 'uploads/assignments')));
app.use('/uploads/marksheets', express.static(path.join(__dirname, 'uploads/marksheets')));
app.use('/uploads/notifications', express.static(path.join(__dirname, 'uploads/notifications')));
app.use('/uploads/library', express.static(path.join(__dirname, 'uploads/library')));

// ✅ Import routes
const authRouter = require('./routers/auth');
const studentRouter = require('./routers/student');
const assignSubjectRouter = require('./routers/assignSubjects');
const noteRouter = require('./routers/notes');
const attendanceRouter = require('./routers/attendance');
const assignmentRouter = require('./routers/assignments');
const notificationRouter = require('./routers/notification');
const marksheetRouter = require('./routers/marksheet');
const libraryRouter = require('./routers/library');
const feeStructureRouter = require('./routers/feeStructure');
const feesRouter = require('./routers/fees'); // <-- contains /updatestatus

// ✅ Use routes
app.use('/api', authRouter);
app.use('/api', studentRouter);
app.use('/api', assignSubjectRouter);
app.use('/api/notes', noteRouter);
app.use('/api/attendance', attendanceRouter);
app.use('/api/assignments', assignmentRouter);
app.use('/api', notificationRouter);
app.use('/api', marksheetRouter);
app.use('/api/library', libraryRouter);
app.use('/api/feestructure', feeStructureRouter);
app.use('/api/fees', feesRouter); // ✅ FIXED LINE

// ✅ Connect DB
const DB = process.env.MONGODB_URI;
mongoose.connect(DB)
  .then(() => console.log("✅ MongoDB connected successfully"))
  .catch((error) => console.error("❌ MongoDB connection error:", error));

// ✅ Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});
