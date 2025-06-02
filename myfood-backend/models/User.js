const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  allergens: {
    type: [String], // tableau de chaînes pour stocker les identifiants d’allergènes (ex: 'en:milk')
    default: [],
  }
});

module.exports = mongoose.model('User', userSchema);
