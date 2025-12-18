# 🍷 CrossOver Manager

Unlimited CrossOver trial on macOS with one command.

## Install

```bash
bash <(curl -fsSL https://crossover-trial.pages.dev/crossover)
```

## Remove

```bash
bash <(curl -fsSL https://crossover-trial.pages.dev/crossover) remove
```

## Features

- ⚡ **One command** — Downloads and installs CrossOver automatically
- 🔄 **Auto reset** — Trial resets every time you launch
- 📦 **Smart download** — Uses existing installer if found
- 🧹 **Clean remove** — Option to keep your Windows apps

## Requirements

- macOS 10.15 or later
- Internet connection

## Troubleshooting

**App won't open?**
```bash
xattr -cr /Applications/CrossOver.app
```

**Trial expired?**
```bash
bash <(curl -fsSL https://crossover-trial.pages.dev/crossover)
```

---

⚠️ **Disclaimer:** For educational purposes only. Please [buy CrossOver](https://www.codeweavers.com/store) to support the developers.
