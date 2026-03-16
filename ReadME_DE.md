# 🤖 AI on Pi

Ein lokaler KI-Chat-Server für den Raspberry Pi – komplett offline, ohne Cloud, ohne Datenweitergabe.  
Betrieben mit **Ollama** und dem **phi3**-Sprachmodell, erreichbar über jeden Browser im Heimnetzwerk.

---

## 📋 Inhaltsverzeichnis

- [Voraussetzungen](#voraussetzungen)
- [Empfohlene Hardware](#empfohlene-hardware)
- [Features](#features)
- [Installation](#installation)
- [Benutzung](#benutzung)
- [Modell](#modell)
- [Projektstruktur](#projektstruktur)

---

## Voraussetzungen

| Was | Mindestversion |
|---|---|
| Raspberry Pi | **5** (4 GB RAM empfohlen) |
| Betriebssystem | **Raspberry Pi OS Lite** (64-bit) |
| Speicher | mind. 8 GB freier Speicher auf der SD-Karte |
| Netzwerk | LAN oder WLAN (nur für die Erstinstallation) |

> **Warum Raspberry Pi OS Lite?**  
> Die Lite-Version kommt ohne Desktop-Umgebung und verbraucht deutlich weniger RAM und CPU.  
> Das gibt dem Sprachmodell mehr Ressourcen – kürzere Antwortzeiten, weniger Ruckler.

---

## Empfohlene Hardware

### 🌬️ Kühlung – wichtig!

> **Es wird dringend empfohlen, den Raspberry Pi mit einem aktiven Luftkühler (Lüfter) auszustatten.**

Das Ausführen eines Sprachmodells ist eine dauerhafte Hochlast-Aufgabe.  
Ohne ausreichende Kühlung wird der Pi sehr schnell gedrosselt (*Thermal Throttling*) – die KI-Antworten werden dadurch deutlich langsamer oder der Pi stürzt ab.

---

## Features

- 💬 **Chat-Interface** direkt im Browser – kein App-Download nötig
- ⚡ **Streaming-Antworten** – Text erscheint Wort für Wort wie bei ChatGPT
- 🧠 **Gesprächsgedächtnis** – die letzten 10 Nachrichten werden als Kontext mitgeschickt
- 📋 **Markdown-Rendering** – Codeblöcke mit Syntax-Highlighting und Kopieren-Button
- 🌐 **Netzwerkzugriff** – erreichbar von jedem Gerät im Heimnetzwerk
- 🔒 **100 % lokal** – keine Daten verlassen das Netzwerk
- 🚀 **Autostart** – optionaler systemd-Dienst startet den Server beim Booten automatisch

---

## Installation

### 1. Raspberry Pi OS Lite vorbereiten

Raspberry Pi OS Lite (64-bit) mit dem **Raspberry Pi Imager** auf die SD-Karte flashen.  
Im Imager unter *Einstellungen* direkt SSH, WLAN und Benutzername konfigurieren.

```bash
# Per SSH verbinden
ssh pi@<IP-Adresse>
```

### 2. Projekt herunterladen

```bash
git clone https://github.com/MartHafner/ai-on-pi.git
cd ai-on-pi
```

### 3. Installer ausführen

```bash
chmod +x install.sh
./install.sh
```

Der Installer erledigt automatisch:

1. System-Update (`apt update & upgrade`)
2. Node.js 20 LTS
3. npm-Abhängigkeiten
4. Ollama
5. Ollama-Dienst starten
6. phi3-Modell herunterladen (~2.3 GB, mit Fortschrittsbalken)
7. Optionaler Autostart via systemd

> ⏱️ Der Download des phi3-Modells dauert je nach Internetverbindung **5–15 Minuten**.

---

## Benutzung

### Server starten

```bash
npm start
```

### Im Browser öffnen

```
http://<IP-des-Pi>:3000
```

Die IP-Adresse des Pi findet man mit:

```bash
hostname -I
```

### Server stoppen

```bash
# Manuell
Ctrl + C

# Falls Autostart aktiviert wurde
sudo systemctl stop local-ai
```

---

## Modell

Das Projekt verwendet standardmäßig **phi3** von Microsoft via **Ollama**.

| Eigenschaft | Wert |
|---|---|
| Modell | phi3 |
| Anbieter | Microsoft (via Ollama) |
| Modellgröße | ~2.3 GB |
| Sprachen | Deutsch & Englisch |
| Besonderheit | optimiert für schwache Hardware |

### Anderes Modell verwenden

In `server.js` die Modellbezeichnung anpassen:

```js
body: JSON.stringify({ model: "phi3", ... })
```

Und in `index.html` das Badge im Header:

```html
<span class="model-badge">phi3 · ollama</span>
```

Verfügbare Modelle unter: [ollama.com/library](https://ollama.com/library)

> Für den Raspberry Pi 5 werden Modelle bis ca. **8 GB** (4-bit quantisiert) empfohlen.  
> Größere Modelle überlasten den RAM und führen zu sehr langen Wartezeiten.

---

## Projektstruktur

```
ai-on-pi/
├── server.js       # Express-Server, leitet Anfragen an Ollama weiter
├── index.html      # Chat-Oberfläche mit Markdown-Renderer
├── style.css       # Dunkles UI-Design
├── package.json    # Node.js Abhängigkeiten
├── install.sh      # Automatischer Installer mit Fortschrittsanzeige
└── README.md       # Diese Datei
```

---

## Lizenz

MIT – frei nutzbar, veränderbar und weiterzugeben.