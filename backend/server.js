

require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json({ limit: '20kb' }));

// Serve the Flutter web application.
const webDirectory = path.join(__dirname, '..', 'build', 'web');

if (fs.existsSync(webDirectory)) {
  app.use(express.static(webDirectory));
}

app.post('/chat', async (req, res) => {
  try {
    const message = req.body.message;

    if (typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({ error: 'Enter a message.' });
    }

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Gemini API key is missing.' });
    }

    const response = await fetch(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': process.env.GEMINI_API_KEY
        },
        body: JSON.stringify({
          system_instruction: {
            parts: [{
              text: 'You are J.A.R.V.I.S., a helpful personal AI assistant. Answer clearly and conversationally.'
            }]
          },
          contents: [{
            role: 'user',
            parts: [{ text: message.trim().slice(0, 8000) }]
          }],
          generationConfig: { maxOutputTokens: 700 }
        })
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error('Gemini error:', data.error?.message || response.status);
      return res.status(502).json({
        error: 'Gemini request failed.',
        details: data.error?.message || String(response.status)
      });
    }

    const reply = data.candidates?.[0]?.content?.parts
      ?.map(part => part.text || '')
      .join('')
      .trim();

    if (!reply) {
      return res.status(502).json({ error: 'Gemini returned no answer.' });
    }

    res.json({ reply });
  } catch (error) {
    console.error('Server error:', error.message);
    res.status(500).json({ error: 'Unable to contact the AI service.' });
  }
});

// Flutter web single-page app fallback.
app.get('*', (req, res, next) => {
  const indexFile = path.join(webDirectory, 'index.html');

  if (fs.existsSync(indexFile)) {
    return res.sendFile(indexFile);
  }

  res.status(503).send(
    'JARVIS web app not built yet. Run: flutter build web'
  );
});

const port = process.env.PORT || 3000;

app.listen(port, '0.0.0.0', () => {
  console.log(`JARVIS backend listening on port ${port}`);
});

