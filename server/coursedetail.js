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

// PostgreSQL connection (adjust credentials as needed)
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'Sahana',
  port: 5432,
});

// Ensure uploads directories exist
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

['video', 'pdf'].forEach(dir => {
  const dirPath = path.join(uploadsDir, dir);
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
});

// Multer config (store files in uploads/video or uploads/pdf)
const syllabusUpload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      let subdir = 'pdf';
      if (file.mimetype && file.mimetype.startsWith('video/')) subdir = 'video';
      cb(null, path.join(uploadsDir, subdir));
    },
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      const prefix = file.mimetype && file.mimetype.startsWith('video/') ? 'video' : 'pdf';
      const ext = path.extname(file.originalname) || '';
      cb(null, `${prefix}-${uniqueSuffix}${ext}`);
    },
  }),
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    const ext = (path.extname(file.originalname) || '').toLowerCase();
    const videoExt = /.(mp4|avi|mov|wmv|flv|webm|mkv)$/;
    const pdfExt = /.pdf$/;

    const isVideo = videoExt.test(ext) && file.mimetype && file.mimetype.startsWith('video/');
    const isPdf = pdfExt.test(ext) && file.mimetype === 'application/pdf';

    if (isVideo || isPdf) {
      cb(null, true);
    } else {
      cb(new Error('Only video (mp4/avi/mov/...) and PDF files are allowed.'));
    }
  },
});

// Initialize DB: create syllabus table if missing
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS syllabus (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        video_url VARCHAR(500),
        pdf_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('Database ready');
  } catch (err) {
    console.error('DB init error:', err);
    throw err;
  }
};

// ================= SYLLABUS ROUTES ================= //

// Healthcheck
app.get('/test', (req, res) => res.json({ success: true, message: 'Server running!' }));

// Create syllabus (POST /api/syllabus)
app.post(
  '/api/syllabus',
  syllabusUpload.fields([{ name: 'video', maxCount: 1 }, { name: 'pdf', maxCount: 1 }]),
  async (req, res, next) => {
    try {
      const { title, content } = req.body;
      if (!title || !content) {
        return res.status(400).json({ success: false, message: 'Title and content are required' });
      }

      const videoUrl = req.files?.video?.[0] ? `/uploads/video/${req.files.video[0].filename}` : null;
      const pdfUrl = req.files?.pdf?.[0] ? `/uploads/pdf/${req.files.pdf[0].filename}` : null;

      const result = await pool.query(
        `INSERT INTO syllabus (title, content, video_url, pdf_url)
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [title, content, videoUrl, pdfUrl]
      );

      res.status(201).json({ success: true, message: 'Syllabus added', data: result.rows[0] });
    } catch (err) {
      // let multer errors fall through or pass to error handler
      next(err);
    }
  }
);

// Read all (GET /api/syllabus)
app.get('/api/syllabus', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM syllabus ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// Read single by id (GET /api/syllabus/:id)
app.get('/api/syllabus/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid ID' });

    const result = await pool.query('SELECT * FROM syllabus WHERE id = $1', [id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Syllabus not found' });

    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// Update syllabus (PUT /api/syllabus/:id)
app.put(
  '/api/syllabus/:id',
  syllabusUpload.fields([{ name: 'video', maxCount: 1 }, { name: 'pdf', maxCount: 1 }]),
  async (req, res, next) => {
    try {
      const id = parseInt(req.params.id, 10);
      if (Number.isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid ID' });

      const existing = await pool.query('SELECT * FROM syllabus WHERE id = $1', [id]);
      if (!existing.rows.length) return res.status(404).json({ success: false, message: 'Syllabus not found' });

      const syllabus = existing.rows[0];
      const { title, content } = req.body;

      // If new files uploaded, use new paths; otherwise keep existing
      const videoUrl = req.files?.video?.[0] ? `/uploads/video/${req.files.video[0].filename}` : syllabus.video_url;
      const pdfUrl = req.files?.pdf?.[0] ? `/uploads/pdf/${req.files.pdf[0].filename}` : syllabus.pdf_url;

      // If a new file replaced an old file, delete old file from disk
      if (req.files?.video?.[0] && syllabus.video_url) {
        const oldVideoPath = path.join(__dirname, syllabus.video_url.replace(/^\/+/, ''));
        if (fs.existsSync(oldVideoPath)) fs.unlinkSync(oldVideoPath);
      }
      if (req.files?.pdf?.[0] && syllabus.pdf_url) {
        const oldPdfPath = path.join(__dirname, syllabus.pdf_url.replace(/^\/+/, ''));
        if (fs.existsSync(oldPdfPath)) fs.unlinkSync(oldPdfPath);
      }

      const result = await pool.query(
        `UPDATE syllabus
         SET title = $1, content = $2, video_url = $3, pdf_url = $4, updated_at = CURRENT_TIMESTAMP
         WHERE id = $5 RETURNING *`,
        [title || syllabus.title, content || syllabus.content, videoUrl, pdfUrl, id]
      );

      res.json({ success: true, message: 'Syllabus updated', data: result.rows[0] });
    } catch (err) {
      next(err);
    }
  }
);

// Delete syllabus (DELETE /api/syllabus/:id)
app.delete('/api/syllabus/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) return res.status(400).json({ success: false, message: 'Invalid ID' });

    const existing = await pool.query('SELECT * FROM syllabus WHERE id = $1', [id]);
    if (!existing.rows.length) return res.status(404).json({ success: false, message: 'Syllabus not found' });

    const { video_url, pdf_url } = existing.rows[0];

    await pool.query('DELETE FROM syllabus WHERE id = $1', [id]);

    // delete files safely
    if (video_url) {
      const videoPath = path.join(__dirname, video_url.replace(/^\/+/, ''));
      if (fs.existsSync(videoPath)) {
        try { fs.unlinkSync(videoPath); } catch (e) { console.warn('Failed to delete video file:', e.message); }
      }
    }
    if (pdf_url) {
      const pdfPath = path.join(__dirname, pdf_url.replace(/^\/+/, ''));
      if (fs.existsSync(pdfPath)) {
        try { fs.unlinkSync(pdfPath); } catch (e) { console.warn('Failed to delete pdf file:', e.message); }
      }
    }

    res.json({ success: true, message: 'Syllabus deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// Multer & general error handler
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    // Multer-specific errors
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ success: false, message: 'File too large. Max 100MB.' });
    }
    return res.status(400).json({ success: false, message: err.message });
  }
  // Other errors (including fileFilter errors thrown as Error)
  if (err) {
    return res.status(500).json({ success: false, message: err.message || 'Server error' });
  }
  next();
});

// 404 handler (any unmatched route)
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Start server after DB init
(async () => {
  try {
    await initDB();
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
})();

// Optional: handle uncaught exceptions / unhandled rejections (graceful logging)

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});

app.use(cors({
  origin: '*' // allow all origins, or replace '*' with your Flutter web URL
}));