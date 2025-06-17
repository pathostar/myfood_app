const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();
const app = express();

// Routes
const authRoutes = require('./routes/auth');
const allergenRoutes = require('./routes/allergens');
const productRoutes  = require('./routes/product');


app.use('/api/product', productRoutes);   //  → /api/product/:barcode

// Middlewares
app.use(cors());
app.use(express.json());

// ➜ Préfixes corrects
app.use('/api/auth', authRoutes);   // /api/auth/...
app.use('/api', allergenRoutes);    // /api/allergens/...
app.use('/api/product', productRoutes);   //  → /api/product/:barcode
// Connexion MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB connecté');
    app.listen(process.env.PORT || 3000, () => {
      console.log(`🚀 Serveur lancé sur http://localhost:${process.env.PORT || 3000}`);
    });
  })
  .catch(err => console.error('Erreur MongoDB :', err));
