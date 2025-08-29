// server.js
const express = require('express');
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// PostgreSQL connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'Sahana',
  port: 5432,
});

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir);

// Multer config
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'astrologer-' + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) cb(null, true);
    else cb(new Error('Only image files are allowed!'));
  },
});

// Initialize DB
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS astrologers (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        specialization VARCHAR(255) NOT NULL,
        language VARCHAR(255) NOT NULL,
        experience INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        minutes INTEGER NOT NULL,
        original_price INTEGER NOT NULL,
        discounted_price INTEGER NOT NULL,
        image_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Database table created successfully');
  } catch (err) {
    console.error('Error creating database table:', err);
  }
};

// ================= ROUTES ================= //

// Test route
app.get('/test', (req, res) => res.json({ success: true, message: 'Server running!' }));

// Add new astrologer
app.post('/api/astrologers', upload.single('image'), async (req, res) => {
  try {
    let {
      name,
      specialization,
      language,
      experience,
      rating,
      minutes,
      originalPrice,
      discountedPrice,
      original_price,
      discounted_price,
    } = req.body;

    // Allow both camelCase and snake_case
    originalPrice = originalPrice || original_price;
    discountedPrice = discountedPrice || discounted_price;

    if (!name || !specialization || !language || !experience || !rating || !minutes || !originalPrice || !discountedPrice) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }

    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const query = `
      INSERT INTO astrologers
        (name, specialization, language, experience, rating, minutes, original_price, discounted_price, image_url)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *
    `;

    const values = [
      name,
      specialization,
      language,
      parseInt(experience),
      parseInt(rating),
      parseInt(minutes),
      parseInt(originalPrice),
      parseInt(discountedPrice),
      imageUrl,
    ];

    const result = await pool.query(query, values);
    res.status(201).json({ success: true, message: 'Astrologer added successfully', data: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get all astrologers
app.get('/api/astrologers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM astrologers ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get single astrologer by ID
app.get('/api/astrologers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM astrologers WHERE id=$1', [id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Astrologer not found' });
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Update astrologer
app.put('/api/astrologers/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    let { name, specialization, language, experience, rating, minutes, originalPrice, discountedPrice, original_price, discounted_price } = req.body;

    // Allow both camelCase and snake_case
    originalPrice = originalPrice || original_price;
    discountedPrice = discountedPrice || discounted_price;

    const existing = await pool.query('SELECT * FROM astrologers WHERE id=$1', [id]);
    if (!existing.rows.length) return res.status(404).json({ success: false, message: 'Astrologer not found' });

    const astro = existing.rows[0];

    let query = `
      UPDATE astrologers SET
        name=$1,
        specialization=$2,
        language=$3,
        experience=$4,
        rating=$5,
        minutes=$6,
        original_price=$7,
        discounted_price=$8,
        updated_at=CURRENT_TIMESTAMP
    `;
    const values = [
      name || astro.name,
      specialization || astro.specialization,
      language || astro.language,
      parseInt(experience) || astro.experience,
      parseInt(rating) || astro.rating,
      parseInt(minutes) || astro.minutes,
      parseInt(originalPrice) || astro.original_price,
      parseInt(discountedPrice) || astro.discounted_price,
    ];

    if (req.file) {
      query += ', image_url=$9 WHERE id=$10 RETURNING *';
      values.push(`/uploads/${req.file.filename}`, id);
    } else {
      query += ' WHERE id=$9 RETURNING *';
      values.push(id);
    }

    const result = await pool.query(query, values);
    res.json({ success: true, message: 'Astrologer updated successfully', data: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete astrologer
app.delete('/api/astrologers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const astro = await pool.query('SELECT image_url FROM astrologers WHERE id=$1', [id]);
    const result = await pool.query('DELETE FROM astrologers WHERE id=$1 RETURNING *', [id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Astrologer not found' });

    // Delete image
    if (astro.rows[0]?.image_url) {
      const imagePath = path.join(__dirname, astro.rows[0].image_url);
      if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
    }

    res.json({ success: true, message: 'Astrologer deleted successfully', data: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// Multer error handler
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ success: false, message: 'File too large. Max 5MB.' });
  }
  res.status(500).json({ success: false, message: err.message || 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Start server
app.listen(PORT, async () => {
  await initDB();
  console.log(`Server running on port ${PORT}`);
});
