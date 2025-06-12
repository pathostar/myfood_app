const express = require('express');
const axios = require('axios');

const router = express.Router();

router.get('/allergens', async (req, res) => {
  try {
    const lang = req.query.lang || 'fr'; // par défaut fr
    const response = await axios.get('https://world.openfoodfacts.org/allergens.json');

    console.log('Nombre de tags récupérés:', response.data.tags.length);

    // liste de prefixes ou mots-clés à exclure
    const excludedPatterns = [
      'gs1-', 'non', 'constituant', 'neant', 'ingredient', 'analytique', 'chapelure'
    ];

    const allergens = response.data.tags
      .map(tag => {
        if (!tag.name.includes(':')) return null;

        const [tagLang, label] = tag.name.split(':');

        if (!tagLang || !label) return null;

        return {
          id: tag.id,
          lang: tagLang,
          name: label,
        };
      })
      .filter(tag => tag !== null && tag.lang === lang)
      .filter(tag => {
        // On filtre les tags indésirables
        return !excludedPatterns.some(pattern => tag.id.includes(pattern));
      })
      .sort((a, b) => a.name.localeCompare(b.name));

    console.log(`Allergènes trouvés en ${lang}: ${allergens.length}`);

    res.json(allergens);
  } catch (error) {
    console.error('Erreur lors de la récupération des allergènes :', error.message);
    res.status(500).json({ message: "Erreur lors de la récupération des allergènes." });
  }
});

module.exports = router;
