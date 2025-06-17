const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName:  { type: String, required: true },
  username:  { type: String, required: true, unique: true },
  password:  { type: String, required: true },
  birthday: { type: Date, required: true },
  allergens: { type: [String], default: [] },
});

module.exports = mongoose.model('User', userSchema);
