/**
 * GET /api/allergens?lang=en
 *  ↳  [{ id:'en:milk', lang:'en', name:'milk' }, … ]
 */
const express = require('express');
const axios   = require('axios');
const router  = express.Router();

/* mots-clés qu’on veut exclure */
const EXCLUDED = [
  'gs1-', 'non', 'constituant', 'neant',
  'ingredient', 'analytique', 'chapelure'
];

router.get('/allergens', async (req, res) => {
  const lang       = (req.query.lang || 'en').toLowerCase(); // en / fr / de …
  const prefix     = `${lang}:`;                             // « en: », « fr: » …

  try {
    /* --------------------------------------------------------
       On ne met PAS de timeout (timeout: 0   ↔   pas de limite)
       -------------------------------------------------------- */
    const { data } = await axios.get(
      'https://world.openfoodfacts.org/allergens.json',
      { timeout: 0 }         // ← ou supprime simplement cette ligne
    );

    const list = data.tags
      .filter(t =>
        typeof t.id === 'string' &&
        t.id.startsWith(prefix) &&
        !EXCLUDED.some(bad => t.id.includes(bad))
      )
      .map(t => ({
        id  : t.id,                       // « en:milk »
        lang: lang,                       // « en »
        name: t.id.slice(prefix.length),  // « milk »
      }))
      .sort((a, b) => a.name.localeCompare(b.name, lang));

    res.json(list);
  } catch (err) {
    console.error('OFF allergens error:', err.message);
    res
      .status(500)
      .json({ message: 'Erreur lors de la récupération des allergènes.' });
  }
});

module.exports = router;
