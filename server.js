const express = require("express");
const cors    = require("cors");
const { encode } = require("@toon-format/toon");

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static(__dirname));

function buildToonPrompt(messages, newPrompt) {
  if (messages.length === 0) return newPrompt;
  const toon = encode({ messages });
  return `${toon}\nuser:${newPrompt}\nassistant:`;
}

app.post("/chat", async (req, res) => {
  const { prompt, history = [] } = req.body;
  if (!prompt) return res.status(400).json({ error: "Prompt fehlt" });

  const fullPrompt = buildToonPrompt(history, prompt);

  try {
    const response = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ 
        model: "phi3", 
        prompt: fullPrompt, 
        stream: true // Wir wollen jedes Wort einzeln
      })
    });

    // Wir setzen den Header auf "ndjson" (Newline Delimited JSON)
    res.setHeader("Content-Type", "application/x-ndjson");

    // Das ist die "Pipe": Was von Ollama reinkommt, geht sofort raus zum Handy
    const reader = response.body.getReader();
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      res.write(value); // Sende das kleine Datenpaket sofort an den Browser
    }
    res.end();

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Ollama Verbindung fehlgeschlagen" });
  }
});

app.listen(3000, "0.0.0.0", () => console.log("Server auf 192.168.1.92:3000"));