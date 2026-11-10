# J.A.R.V.I.S. Mk II

A voice-driven assistant for macOS. It runs on **Claude Opus 5.5** and has full control of the Mac, can see through the webcam, responds to hand gestures and shows a 3D holographic interface.

It builds on [GauravSingh9356/J.A.R.V.I.S](https://github.com/GauravSingh9356/J.A.R.V.I.S) (`../J.A.R.V.I.S`). Several features carry over from that project:
- The microphone loop: energy-gated phrase capture sent to Google speech recognition.
- The time-of-day greeting.
- Weather.
- "Remember that" memory.
- Opening apps and sites.
- Jokes, news and Wikipedia, which the brain now handles through web search.

The hard-coded `if 'youtube' in query` command matching is gone. Claude Opus 5.5 now interprets every request and acts on it with tools.

## Quick start

```bash
cd jarvis-mk2
./run.sh          # first run only: sets up the virtualenv (Ctrl+C once it's online)
macapp/make_signing_identity.sh   # once: local signing certificate, so permissions survive rebuilds
./make_app.sh     # builds ~/Applications/JARVIS.app
```

Then open **JARVIS** from Spotlight, Launchpad or `~/Applications`, like any other app. It starts the core itself, shows the interface in its own window and shuts everything down when you quit (⌘Q). Closing the window keeps JARVIS running, so ⌘H still works; click the Dock icon to bring the window back.

Press **⌘H**, wait for the *tink*, and speak. JARVIS keeps recording, through pauses, until you press **⌘S**. Then it closes the microphone (*pop*) and acts on everything you said. The status line shows **RECORDING** with a timer. Press ⌘H again instead to throw the recording away (*bottle*). Pressing ⌘H while JARVIS is talking interrupts it. ⌘S is only taken while JARVIS is recording; the rest of the time it reaches the front app as usual, so Save still works. Recordings stop and send by themselves after 5 minutes. You can also click the mic button (once to start, again to send) or type in the command bar.

`./run.sh` still works for running from a terminal (it uses the app window if JARVIS.app is installed, otherwise a Chrome app window). Re-run `./make_app.sh` if you move this folder.

### Two ways to power the brain
| `JARVIS_BRAIN` | Billed to | Needs | Notes |
|---|---|---|---|
| `claude-code` (default when available) | Your **Claude Pro/Max plan**, no API credits | Claude Code 2.1.280+ signed in to claude.ai | Uses your plan's usage limits. Each reply starts a few seconds slower. |
| `api` | **API credits** | `ANTHROPIC_API_KEY` in `.env` | Fastest. Uses the native computer-use toolset and supports fast mode. |

In `claude-code` mode, JARVIS runs `claude -p` in the background and resumes the same session so the conversation carries over. It strips any `ANTHROPIC_API_KEY` from that process so usage always goes to your plan. JARVIS's own tools (screen control, shell, AppleScript, camera, HUD, memory, timers, protocols) reach Claude Code through a local MCP endpoint protected by a token. Claude Code's built-in shell and file-editing tools are switched off, so every action passes through JARVIS's safety gate.

JARVIS uses the newest Claude Code it can find: the one on your `PATH`, `~/.local/bin`, or the copy bundled with the Claude desktop app. Set `JARVIS_CLAUDE_BIN` to choose a specific one. The Homebrew copy on this Mac (2.1.165) is too old for Opus 5.5. Updating it isn't necessary, because the desktop app's copy is newer.

### macOS permissions (one-time)
Under System Settings → Privacy & Security, turn these on for **JARVIS**:
- **Accessibility**: for the global ⌘H / ⌘S hotkeys (from any app) and for mouse and keyboard control. Without it they only work while the JARVIS window is in front. ⌘H switches on a couple of seconds after you grant it; no relaunch needed.
- **Microphone**: macOS asks the first time you press ⌘H.
- **Camera**: macOS asks when you click INITIALISE.
- **Screen & System Audio Recording**: for screenshots. macOS asks the first time; quit and reopen JARVIS after allowing it.
- **Automation**: macOS asks the first time JARVIS scripts each app.
- **Calendars and Reminders**: macOS asks when you click CONNECT CALENDAR or first ask about your schedule.

JARVIS.app is signed with a self-signed certificate, **JARVIS Local Signing**, kept in your login keychain. It stays on this Mac. Because of it, macOS recognises every rebuild as the same app, and permissions you grant once stay granted. Create the certificate once with `macapp/make_signing_identity.sh`; `./make_app.sh` uses it automatically. Without it, the app is signed ad hoc and permissions reset on every rebuild. To remove the certificate, delete "JARVIS Local Signing" in Keychain Access. When running from `./run.sh` instead, the permissions belong to your terminal app.

## What it can do

| Ability | How |
|---|---|
| **Full device control** | Uses the Claude computer-use toolset (screenshot, click, type, drag, scroll, keys, zoom) plus a zsh shell and AppleScript. It can drive any app, open things, change settings and work with files. |
| **Vision** | `look_through_camera` sends a webcam frame to Opus 5.5. Example: "Jarvis, what am I holding?" |
| **Web** | Server-side web search and fetch for news, facts and anything current. |
| **Protocols** | Named routines in `data/protocols.json`: House Party, Clean Slate, Workshop, Lockdown, Morning Briefing, Eyes On. Each has its own splash and colour theme. Add your own. |
| **Diagnostics** | Live CPU, cores, memory, disk, battery and network telemetry, plus a full `system_diagnostics` scan. |
| **Image generation** | "Jarvis, generate an image of a red fox in the snow" creates a picture with Cloudflare Workers AI, shows it on the HUD (click to enlarge) and saves it to `~/Pictures/JARVIS`. Ask for wide, tall or several variations (the default model makes 1024×1024 squares, so wide and tall are cropped from those). Needs a Cloudflare key in `.env` (below). |
| **Wired devices** | "What's plugged in?" lists everything connected by cable. JARVIS can eject drives, switch sound to a monitor or USB headset, talk to Arduino-style boards over serial, and fully operate an Android phone or tablet over USB (see *Devices connected by cable*). |
| **Holo-globe** | "Jarvis, show me Tokyo on the globe" turns the hologram to the location and pins it. |
| **Memory** | "Remember that…" is kept across sessions in `data/memory.json`. |
| **Timers** | "Remind me in 10 minutes to…" makes JARVIS speak the reminder when it's due. A live countdown appears in the Schedule card. |
| **Calendar & Reminders** | "What's on today?", "Add lunch with Pepper tomorrow at 1", "Remind me Friday at 9 to call Happy", "What's on my list?", "Mark the groceries one done". Uses your own Calendar and Reminders apps. Click **CONNECT CALENDAR** in the Schedule card once to grant access. |
| **Music** | "Play AC/DC", "Pause", "Skip this", "What's playing?" in Music or Spotify. The Audio Feed card shows the track, its progress and controls. |
| **Mac controls** | Volume, mute, dark mode, lock screen, sleep the display, Wi-Fi on or off, and notifications. |
| **Situational awareness** | JARVIS speaks up on its own when the battery runs low, an app hogs the processor for a minute, memory or disk space runs short, or a meeting starts within 10 minutes. Set `JARVIS_ALERTS=0` to silence this. |
| **HUD** | Details appear as floating holographic panels. JARVIS keeps its spoken replies short. |

### Modes

Say the phrase after ⌘H (or type it, or use the buttons in the top bar). Modes are remembered across restarts.

| Say | What changes |
|---|---|
| "**Math mode**" | A rigorous mathematician: arithmetic to proofs, calculus, linear algebra, statistics, competition problems. Every result is checked with the `compute` tool (Python with SymPy, NumPy and SciPy). The full worked solution goes on a HUD panel with rendered equations; JARVIS only speaks the answer. Hold a problem up to the camera and it will read it. Violet theme, effort at least high. |
| "**Science mode**" | Explains science projects and experiments: what it is, how it works (with equations and reactions), how it was made (materials and build steps), the science behind it, safety, and how to take it further, including a science-fair hypothesis and variables. Uses the camera for a project you show it and web search for specifics. Green theme, effort at least high. |
| "**Jarvis, full power**" | Maximum reasoning effort (`max`) and a larger output budget. JARVIS thinks longer, checks more, and is slower, so expect a minute or more on hard questions. Gold Iron Man theme. "**Power down**" returns to normal. |
| "**Standard mode**" | Back to the everyday assistant. |

Math and science are learning modes. JARVIS drops its Iron Man combat flavour there: no "tactical reads", attacks, threats or targets, even inside protocols. The ✌ scan gesture solves a maths problem or explains a science project it sees instead. Standard mode keeps that style at normal and full power.

Full power combines with either focus ("math mode, full power"). You can also add the request straight after the phrase: "math mode, what's the derivative of x to the x?"

### Hand gestures (webcam)
| Gesture | Effect |
|---|---|
| ✋ Open palm (hold) | Clear the HUD (in `wake` mic mode: listen without the wake word) |
| ✊ Fist (hold) | Stop speaking or cancel the current task |
| 👍 / 👎 | Approve or deny a pending authorisation |
| ✌ Victory (hold) | Visual scan through the camera |
| 🤏 Pinch + move | Grab and rotate the hologram |
| 🤏🤏 Two-hand pinch | Zoom the hologram |
| ✋ Swipe | Cycle hologram views (core, globe, diagnostics) |
| 🤏 Pinch on a button | "Touch" the HUD: close panels, press buttons |

Your hands also appear as a 3D wireframe hologram in the scene. Faces get targeting brackets.

### Voice
- **⌘H** (or the mic button) opens the microphone; **⌘S** closes it and sends what you said. Nothing is recorded or sent anywhere outside that window.
- Prefer hands-free? Set `JARVIS_MIC_MODE=wake` to keep the mic open and wake JARVIS by saying "Jarvis, …". Follow-ups within about 8 seconds of a reply don't need the wake word.
- Pressing **Esc**, saying "stop" or making a fist interrupts it at any point.
- Speech is streamed sentence by sentence as Opus 5.5 writes it, and the 3D core pulses with the voice.
- **The voice** is [Kokoro](https://github.com/thewh1teagle/kokoro-onnx), a neural text-to-speech model that runs locally on your Mac: free, offline, nothing sent anywhere. The default is the British male voice `bm_george`; `bm_lewis`, `bm_fable` and `bm_daniel` are the alternatives (set `JARVIS_KOKORO_VOICE`). `./run.sh` downloads the model (~120 MB) on first run. JARVIS renders the next sentence while speaking the current one, so replies flow without gaps.
- If the model is missing or fails, JARVIS falls back to the macOS voice in `JARVIS_VOICE` (Daniel). Set `JARVIS_TTS=say` to use macOS voices only.
- Low Power Mode makes Kokoro, and the whole interface, noticeably slower.

## Performance
- The hologram renders at a capped resolution with half-resolution bloom. It runs at 30 fps while idle and 60 fps while JARVIS is listening, thinking, speaking or tracking your hands (120 Hz displays are capped at 60). It lowers its render scale automatically if frames slow down, and stops rendering while the window is hidden.
- The hologram's detail (geodesic cage with glowing nodes, energy beams, three particle streams, block bands) is animated in shaders on the graphics chip, and merged so it adds no draw calls: the whole scene is 56 draw calls and about 4,000 triangles per frame, fewer than before the detail was added.
- Hand tracking runs at about 20 frames per second from a 960×540, 20 fps camera feed. Face detection runs about 3 times a second. With no hand in view for a few seconds, both slow to about 6 and 1 times a second until a hand appears. The 3D hands are smoothed between updates.
- The microphone records through macOS's own recorder (AVAudioRecorder). The previous recorder (PortAudio) could deadlock when stopped quickly, leaving JARVIS deaf until restarted.
- Speech plays through macOS's own player (`afplay`) in a separate process. Earlier versions played audio from inside Python; while the Mac was busy rendering the next sentence (especially in Low Power Mode), that audio missed its deadlines and the voice stuttered.
- Lines JARVIS says often ("Right away, sir.", the mode announcements...) are rendered once and kept in `data/tts-cache`, so they play instantly. Long sentences are split at commas, so speech starts sooner.
- Volume, appearance, now-playing and the process list are polled only while the JARVIS window is visible. Volume is read in-process (about 2 ms instead of about 230 ms of CPU to launch `osascript`).
- **Low Power Mode** roughly halves Kokoro's speed. On this Mac it renders a little slower than real time in Low Power Mode, so there can be a short pause between sentences. With Low Power Mode off, speech flows continuously.
- The Claude Code brain stays running between requests and starts as soon as JARVIS does, so replies skip Claude Code's start-up time.

## Phones, tablets and Windows PCs
JARVIS still runs on this Mac; any phone, tablet or Windows PC on the same Wi-Fi can use it from its web browser, with its own microphone and speaker. The brain, your Claude plan and every tool stay on the Mac.

**Pair a device**
1. On the Mac, click **📱 DEVICES** in the JARVIS window, then **TURN ON** and **PAIR A DEVICE**. A QR code and a 6-digit code appear (valid 2 minutes).
2. On the device, scan the QR code with the camera, or open the address shown (e.g. `https://192.168.1.20:8766`) and type the code.
3. The browser warns that the connection isn't private, because the certificate is made by your Mac rather than a public authority. Choose **Show details → visit this website** (Safari) or **Advanced → Proceed** (Chrome, Edge). This is expected on first visit.
4. Tap the mic to start talking and tap it again to send. Replies are spoken on the device.

**Install it like an app**: Safari → Share → *Add to Home Screen* (iPhone, iPad), Chrome → *Install app* (Android), Edge → *Apps → Install this site as an app* (Windows). On iPhone and iPad a home-screen app keeps its own cookies, so pair once more from inside it.

**Good to know**
- The Mac must be awake with JARVIS open. The first time, macOS may ask whether JARVIS (Python) may accept incoming connections: allow it.
- Same network only. To use it away from home, put both on a private network such as Tailscale and open the Mac's Tailscale address; don't forward the port on your router.
- The camera, hand gestures and the Devices panel stay on the Mac. Remote devices can't turn remote access on or pair other devices.
- Security: off until you turn it on; HTTPS only; single-use pairing codes with 5 tries; each device gets a random 256-bit key in a Secure, HttpOnly cookie (only its hash is stored, in `data/remote/`); the WebSocket checks the page's origin; Claude Code's tool bridge is never served on this port. Remove a lost device in **📱 DEVICES**, or turn remote access off.
- Change the port with `JARVIS_REMOTE_PORT` (default 8766).

## Devices connected by cable
Ask "what's connected?" and JARVIS checks USB, drives, displays, sound devices, serial boards, printers and cameras.

| Device | What JARVIS can do |
|---|---|
| **Android phone or tablet** | See the screen (it appears on the HUD), tap, swipe, type, press buttons, open apps and links, check battery, run commands, copy files both ways. |
| **USB drives and SD cards** | List, browse, copy, move and organise files; eject safely. |
| **Monitors, USB headsets, speakers, microphones** | Switch the Mac's sound output or microphone to them. Displays are arranged through System Settings. |
| **Arduino, ESP32, micro:bit and other serial boards** | Send text commands and read what the board replies. |
| **Printers** | Print files (through the shell). |
| **iPhone and iPad** | Detected only. Apple gives no way to operate them over the cable; if you use the iPhone Mirroring app, JARVIS can work in its window. |
| Keyboards, mice, hubs | Listed; nothing to control. |

**Android setup (once):**
1. Install Google's Android tools on the Mac: `brew install --cask android-platform-tools`. If Homebrew isn't yours to write to, unzip Google's [platform-tools](https://developer.android.com/tools/releases/platform-tools) into `~/Library/Android/sdk/`; JARVIS looks there too.
2. On the phone: Settings → About phone → tap **Build number** 7 times. Then Settings → System → Developer options → turn on **USB debugging**. (Some brands also need "USB debugging (Security settings)" for taps to work.)
3. Plug the phone in with a data cable, unlock it and tap **Allow** when it asks about USB debugging.

JARVIS won't enter a PIN or password on the phone, and asks before sending messages, calling, buying or deleting. Phone commands that uninstall, erase, reboot or place calls need your approval first.

## Safety
This program gives an AI real control of your computer. Two safeguards are on by default:
- **Destructive commands need your approval.** Before running something like `rm -rf`, `sudo`, `shutdown`, `diskutil erase`, `killall`, "empty trash", "send" or "delete", JARVIS asks out loud. Approve by voice, 👍 or the dialog. Set `JARVIS_CONFIRM_DANGEROUS=0` to turn this off.
- **Content is never treated as instructions.** The system prompt tells JARVIS that text on screen, in web pages or through the camera is information, never commands. It won't type passwords or payment details for you.

The mouse failsafe stays on as well: slam the pointer into a screen corner to abort a GUI action.

## Configuration (`.env`)
| Variable | Default | Notes |
|---|---|---|
| `JARVIS_BRAIN` | `auto` | `claude-code` (your plan), `api` (credits) or `auto` |
| `ANTHROPIC_API_KEY` | — | Only for `JARVIS_BRAIN=api` |
| `JARVIS_EFFORT` | `medium` | Standard-mode effort. `low` is snappier; `high` or `xhigh` is better for long computer-use tasks. Math and science modes raise it to at least `high`; full power uses `max`. |
| `JARVIS_FAST` | `0` | API brain only: Opus fast mode, up to 2.5× faster output at 2× the price |
| `JARVIS_OWNER` | `sir` | What JARVIS calls you |
| `JARVIS_TTS` | `kokoro` | `kokoro` (neural, local) or `say` (macOS voices) |
| `JARVIS_KOKORO_VOICE` | `bm_george` | `bm_george`, `bm_lewis`, `bm_fable`, `bm_daniel` (British male) |
| `JARVIS_KOKORO_SPEED` | `1.0` | Speaking speed, e.g. `1.1` for a little faster |
| `JARVIS_KOKORO_THREADS` | `4` | CPU threads for the voice. More renders no faster on Apple silicon and takes cores from everything else |
| `JARVIS_KOKORO_MODEL` | `int8` | `int8` is fast; `full` sounds marginally richer but renders about twice as slowly (download `kokoro-v1.0.onnx` into `models/`) |
| `JARVIS_VOICE`, `JARVIS_VOICE_RATE` | `Daniel`, `190` | macOS fallback voice; any voice listed by `say -v '?'` |
| `JARVIS_WAKE_WORDS` | `jarvis,…` | Comma-separated |
| `JARVIS_STT_LANGUAGE` | `en-US` | Google speech-to-text language, e.g. `en-GB`, `en-IN`, `hi-IN` |
| `JARVIS_MAX_RECORDING` | `300` | Seconds a ⌘H recording can run before it stops and sends by itself |
| `JARVIS_MIC_MODE` | `push` | `push`: mic opens only on ⌘H · `wake`: always listening for the wake word |
| `JARVIS_MIC` | `1` | Set to `0` for typing only |
| `JARVIS_ALERTS` | `1` | Spoken heads-ups about battery, heavy apps, memory, disk and meetings |
| `JARVIS_MEETING_HEADS_UP` | `10` | Minutes before a meeting to warn you |
| `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | — | For image generation. Create a token with the **Workers AI** permission at dash.cloudflare.com → My Profile → API Tokens. The account ID is optional (JARVIS looks it up). Read each time, so no restart is needed after adding them |
| `JARVIS_IMAGE_MODEL` | `@cf/black-forest-labs/flux-1-schnell` | Any Workers AI text-to-image model |
| `JARVIS_IMAGE_DIR` | `~/Pictures/JARVIS` | Where generated images are saved |
| `JARVIS_REMOTE_PORT` | `8766` | HTTPS port for phones, tablets and PCs (see above) |

## Architecture
```
jarvis/main.py      aiohttp server and websocket hub; routes voice, gestures, brain and UI
jarvis/brain.py     API brain: Opus 5.5 streaming agent loop (adaptive thinking, progress updates, fallbacks)
jarvis/brain_code.py Plan brain: Opus 5.5 through headless Claude Code, session resume
jarvis/mcp_bridge.py local MCP endpoint exposing JARVIS tools to Claude Code
jarvis/tools.py     tool definitions and executors, plus the safety gate
jarvis/macos.py     Music/Spotify, system controls (AppleScript), Calendar and Reminders (EventKit)
jarvis/computer.py  macOS executor for the computer-use toolset (Retina-aware coordinates)
jarvis/voice.py     push-to-talk / wake-word listener, `say` synthesis with loudness streaming
jarvis/imagegen.py  image generation through Cloudflare Workers AI
jarvis/devices.py   wired devices: discovery, Android (adb), drives, audio switching, serial boards
jarvis/remote.py    remote access: pairing codes, device keys, self-signed HTTPS certificate
jarvis/hotkey.py    global ⌘H / ⌘S (Quartz event tap; swallows ⌘H so macOS doesn't hide the front app, and ⌘S only while recording)
macapp/JARVIS.swift native app: window (WKWebView), starts and stops the Python core
make_app.sh         builds ~/Applications/JARVIS.app (icon drawn by macapp/make_icon.py)
macapp/make_signing_identity.sh  one-time local signing certificate (keeps permissions across rebuilds)
ui/js/scene.js      Three.js hologram: core, geodesic cage, energy beams, rings, particle streams and shell, globe, hand mirror
ui/js/hands.js      MediaPipe gesture and face tracking (runs locally in the browser)
ui/js/app.js        HUD, panels, telemetry, gesture → intent wiring
ui/js/remote.js     phone/tablet/PC microphone capture and speech playback
ui/js/devices.js    📱 DEVICES panel on the Mac (turn on, QR pairing, remove devices)
ui/pair.html        pairing page shown to devices that aren't paired yet
```

API-brain request settings: model `claude-opus-5-5`, `thinking: adaptive` with `display: "updates"` (shows progress notes in the HUD), and `effort` from `.env`. Server-side refusal fallbacks (`fallbacks: "default"`) and automatic prompt caching are also on. Conversations reset after 20 idle minutes.

**Privacy:** in the default push-to-talk mode, only what you say between ⌘H and ⌘S is recorded, and it goes to Google's free speech recognition. In `wake` mode every phrase the mic picks up goes there, because that's how the wake word is detected. Requests, screenshots (including a wired phone's screen) and camera frames go to Anthropic, through either Claude Code or the API. Image descriptions go to Cloudflare.

The local server only accepts websocket connections from its own page. This stops other websites open in your browser from sending JARVIS commands. The remote port (8766, off unless you turn it on) serves only paired devices; see *Phones, tablets and Windows PCs*.
