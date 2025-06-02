const express = require('express');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

const router = express.Router();

router.post('/register-step1', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password)
    return res.status(400).json({ message: 'Champs requis' });

  const exists = await User.findOne({ username });
  if (exists)
    return res.status(409).json({ message: 'Utilisateur déjà existant' });

  const hashedPassword = await bcrypt.hash(password, 10);

  const newUser = new User({
    username,
    password: hashedPassword,
    allergens: [], // vide pour le moment
  });

  await newUser.save();

  res.status(201).json({
    message: 'Étape 1 réussie. Passez à la sélection des allergènes.',
    userId: newUser._id,
  });
});

router.post('/register-step2', async (req, res) => {
  const { userId, allergens } = req.body;

  if (!userId || !Array.isArray(allergens)) {
    return res.status(400).json({ message: 'userId ou allergènes manquants' });
  }

  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { allergens: allergens },
      { new: true }
    );

    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

    res.status(200).json({ message: 'Inscription finalisée avec allergènes.', user });
  } catch (error) {
    console.error('Erreur dans /register-step2 :', error.message);
    res.status(500).json({ message: 'Erreur lors de la mise à jour des allergènes' });
  }
});

router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password)
    return res.status(400).json({ message: 'Champs requis' });

  const user = await User.findOne({ username });
  if (!user)
    return res.status(401).json({ message: 'Identifiants invalides' });

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid)
    return res.status(401).json({ message: 'Mot de passe incorrect' });

  // Générer un token
  const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
    expiresIn: '24h',
  });

  res.json({
    message: 'Connexion réussie',
    token,
    user: {
      id: user._id,
      username: user.username,
      allergens: user.allergens,
    },
  });
});


module.exports = router;
