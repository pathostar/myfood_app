const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

const app = express();
dotenv.config();

// Import des routes
const authRoutes = require('./routes/auth');
const allergenRoutes = require('./routes/allergens');

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/api', authRoutes);
app.use('/api', allergenRoutes);

// Connexion MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB connecté');
    app.listen(process.env.PORT || 3000, () => {
      console.log(`🚀 Serveur lancé sur http://localhost:${process.env.PORT || 3000}`);
    });
  })
  .catch(err => console.error('Erreur MongoDB :', err));
