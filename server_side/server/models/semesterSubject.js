const mongoose = require('mongoose');

const semesterSubjectSchema = new mongoose.Schema({
  semester: { type: String, required: true, unique: true },
  subjects: { type: [String], required: true }
});

module.exports = mongoose.model('SemesterSubject', semesterSubjectSchema);
