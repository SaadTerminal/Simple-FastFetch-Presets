# Simple-FastFetch-Presets

**Configure a Fastfetch preset with a simple click — no manual JSON editing required.**

Simple Fastfetch Presets is a lightweight shell script that gives you four ready-made `fastfetch` configurations, applies the one you choose, backs up your existing config automatically, and optionally adds Fastfetch to your shell startup.

The script doesn't install Fastfetch itself, it just makes configuring it painless.

Built and tested on **Linux Mint** with the default Mint terminal (GNOME Terminal) and the default Ubuntu Regular font, but **it's designed to work with any terminal emulator and any font.**

---

## Features

- **First-run friendly** — no JSON knowledge needed
- **Non-destructive** — automatic timestamped backups
- **Scriptable** — flags for non-interactive/automated setups
- **No dependencies beyond Fastfetch itself** — it's one bash script
- **Easy to fork** — want your own preset? Drop a `.jsonc` file in `presets/` and add it to the list

---

## Requirements

- Any Linux system
- `fastfetch` installed
- `bash`

If `fastfetch` isn't installed, the script will offer to install it for you via `apt`.

---

## The Four Presets

| # | Preset | What You Get |
|---|--------|--------------|
| 1 | **Minimal** | No logo, just the essentials |
| 2 | **Compact** | Distro ASCII logo + balanced info |
| 3 | **Compact + IP** | Distro ASCII logo + balanced info + local IP included |
| 4 | **Full** | Everything — hardware, network, packages, colors, logo |

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/SaadTerminal/Simple-FastFetch-Presets.git
```

### 2. Enter the directory

```bash
cd Simple-FastFetch-Presets
```

### 3. Make the script executable

```bash
chmod +x setup.sh
```

### 4. Run it

```bash
./setup.sh
```
*⚠️  If fastfetch is installed in the root directory, you need to run the script as sudo ⚠️*

That's it. The script will walk you through the rest interactively.

---

## Usage

### Interactive mode (default)

Just run the script and follow the prompts:

```bash
./setup.sh
```

You'll be asked to:
1. Confirm your system and Fastfetch installation (it can install Fastfetch for you)
2. Pick a preset (1–4)
3. Decide whether to add Fastfetch to your shell startup

### Command-line options

```
Usage: ./setup.sh [OPTIONS]

Options:
  -c, --config TYPE     minimal | compact | compact-ip | full
  -n, --non-interactive Run without prompts (defaults to minimal)
  --skip-shell          Skip shell startup integration
  -h, --help            Show this help
```

### Examples

Apply the full preset without any prompts:

```bash
./setup.sh --config full
```

Apply the compact preset but don't touch your shell config:

```bash
./setup.sh -c compact --skip-shell
```

Fully automated, minimal, no shell changes:

```bash
./setup.sh -n --skip-shell
```

---

## What Happens to My Existing Config?

Your current Fastfetch config is **never overwritten silently**. If a config already exists at:

```
~/.config/fastfetch/config.jsonc
```

it gets backed up first, like this:

```
config.jsonc.backup.20260825_143012
```

So you can always roll back.

---

## Shell Integration

If you choose to add Fastfetch to your shell startup, the script appends a safe, guarded block to the correct file for your shell:

- **bash** → `~/.bashrc`
- **zsh** → `~/.zshrc`
- **fish** → `~/.config/fish/config.fish`

The block looks like this:

```bash
# Fastfetch - System Information Display
if command -v fastfetch &> /dev/null; then
    fastfetch
fi
```

It won't be added twice — the script checks first. If your shell isn't supported, it tells you exactly what to add manually instead of guessing.

---

## Project Structure

```
Simple-FastFetch-Presets/
├── presets/
│   ├── minimal.jsonc
│   ├── compact.jsonc
│   ├── compact-ip.jsonc
│   └── full.jsonc
├── setup.sh
├── LICENSE
└── README.md
```

---

## Contributing

This is a first public project, so feedback, issues, and pull requests are genuinely welcome. If you make a preset you like, open a PR — the more variety, the better.

---

## License

See the [LICENSE](https://github.com/SaadTerminal/Simple-FastFetch-Presets/blob/main/LICENSE) file in the repository.

---

## Links

- **Repository:** https://github.com/SaadTerminal/Simple-FastFetch-Presets
- **Fastfetch:** https://github.com/fastfetch-cli/fastfetch

---

