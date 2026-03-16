# AI on Pi

A local AI chat server for the Raspberry Pi – fully offline, no cloud, no data sharing.  
Powered by **Ollama** and the **phi3** language model, accessible from any browser on your home network.

---

## Table of Contents

- [Requirements](#requirements)
- [Recommended Hardware](#recommended-hardware)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Model](#model)
- [Project Structure](#project-structure)

---

## Requirements

| What | Minimum |
|---|---|
| Raspberry Pi | **5** (4 GB RAM recommended) |
| Operating System | **Raspberry Pi OS Lite** (64-bit) |
| Storage | at least 8 GB free space on the SD card |
| Network | LAN or Wi-Fi (only required for initial setup) |

> **Why Raspberry Pi OS Lite?**  
> The Lite version ships without a desktop environment and uses significantly less RAM and CPU.  
> This gives the language model more resources – faster response times and fewer slowdowns.

---

## Recommended Hardware

### Cooling – important!

> **It is strongly recommended to equip the Raspberry Pi with an active air cooler (fan).**

Running a language model is a sustained high-load task.  
Without adequate cooling, the Pi will throttle very quickly (*thermal throttling*) – AI responses will become noticeably slower or the Pi may crash.

---

## Features

- **Chat interface** directly in the browser – no app download required
- **Streaming responses** – text appears word by word, just like ChatGPT
- **Conversation memory** – the last 10 messages are sent as context
- **Markdown rendering** – code blocks with syntax highlighting and copy button
- **Network access** – reachable from any device on your home network
- **100% local** – no data leaves your network
- **Autostart** – optional systemd service starts the server automatically on boot

---

## Installation

### 1. Prepare Raspberry Pi OS Lite

Flash Raspberry Pi OS Lite (64-bit) to your SD card using the **Raspberry Pi Imager**.  
In the Imager under *Settings*, configure SSH, Wi-Fi and your username directly.

```bash
# Connect via SSH
ssh pi@<IP-address>
```

### 2. Clone the project

```bash
git clone https://github.com/MartHafner/ai-on-pi.git
cd ai-on-pi
```

### 3. Run the installer

```bash
chmod +x install.sh
./install.sh
```

The installer handles everything automatically:

1. System update (`apt update & upgrade`)
2. Node.js 20 LTS
3. npm dependencies
4. Ollama
5. Start Ollama service
6. Download phi3 model (~2.3 GB, with progress bar)
7. Optional autostart via systemd

> Downloading the phi3 model takes **5–15 minutes** depending on your internet connection.

---

## Usage

### Start the server

```bash
npm start
```

### Open in browser

```
http://<Pi-IP-address>:3000
```

Find the Pi's IP address with:

```bash
hostname -I
```

### Stop the server

```bash
# Manually
Ctrl + C

# If autostart was enabled
sudo systemctl stop local-ai
```

---

## Model

This project uses **phi3** by Microsoft via **Ollama** by default.

| Property | Value |
|---|---|
| Model | phi3 |
| Provider | Microsoft (via Ollama) |
| Model size | ~2.3 GB |
| Languages | English & German |
| Notable | optimized for low-end hardware |

### Using a different model

Change the model name in `server.js`:

```js
body: JSON.stringify({ model: "phi3", ... })
```

And update the badge in `index.html`:

```html
<span class="model-badge">phi3 · ollama</span>
```

Browse available models at: [ollama.com/library](https://ollama.com/library)

> Models up to ~**8 GB** (4-bit quantized) are recommended for the Raspberry Pi 5.  
> Larger models will exhaust the available RAM and result in very long response times.

---

## Project Structure

```
ai-on-pi/
├── server.js       # Express server, forwards requests to Ollama
├── index.html      # Chat UI with Markdown renderer
├── style.css       # Dark UI design
├── package.json    # Node.js dependencies
├── install.sh      # Automated installer with progress display
└── README.md       # This file
```

---

## License

MIT – free to use, modify and distribute.
