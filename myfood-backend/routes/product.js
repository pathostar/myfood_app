const express = require('express');
const axios   = require('axios');
const router  = express.Router();

/**
 * GET /api/product/:barcode?lang=fr
 * Renvoie { name, nutriscore, allergens[] } dans la langue demandée.
 */
router.get('/:barcode', async (req, res) => {
  const { barcode } = req.params;
  const lang = req.query.lang || 'fr';

  const url =
    `https://world.openfoodfacts.org/api/v0/product/${barcode}.json` +
    `?fields=product_name,nutriscore_grade,allergens&lc=${lang}`;

  try {
    const { data } = await axios.get(url);

    if (data.status !== 1) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    const allergens = (data.product.allergens || '')
      .split(/\s*,\s*/)
      .filter(Boolean); // ex. ["lait","arachides"]

    res.json({
      name      : data.product.product_name,
      nutriscore: data.product.nutriscore_grade,
      allergens
    });
  } catch (err) {
    console.error('OFF error:', err.message);
    res.status(500).json({ message: 'Erreur OpenFoodFacts' });
  }
});

module.exports = router;
