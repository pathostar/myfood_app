const express = require('express');
const axios = require('axios');

const router = express.Router();

router.get('/allergens', async (req, res) => {
  try {
    const response = await axios.get('https://world.openfoodfacts.org/allergens.json');

    const allergens = response.data.tags.map(tag => ({
      id: tag.id,
      name: tag.name,
    }));

    res.json(allergens);
  } catch (error) {
    console.error('Erreur lors de la récupération des allergènes :', error.message);
    res.status(500).json({ message: "Erreur lors de la récupération des allergènes." });
  }
});

module.exports = router;
