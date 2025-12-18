# 🍷 CrossOver Manager

> **Unlimited CrossOver trial on macOS with one command.**

CrossOver lets you run Windows applications on Mac without a Windows license. This tool automates installation and manages the trial period.

## 📦 Quick Install

```bash
bash <(curl -fsSL https://crossover-trial.pages.dev/crossover)
```

## 🗑️ Uninstall

```bash
bash <(curl -fsSL https://crossover-trial.pages.dev/crossover) remove
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **One Command** | Downloads, installs, and configures CrossOver automatically |
| **Auto Version** | Always fetches the latest version from CodeWeavers |
| **Smart Detection** | Uses existing installer if found in Downloads/Desktop |
| **Trial Auto-Reset** | Resets trial every time you launch CrossOver |
| **Upgrade Prompt** | Notifies when newer version is available |
| **Clean Uninstall** | Option to preserve Windows apps (bottles) |

## 🔧 How It Works

### For New Users
1. Downloads latest CrossOver from [CodeWeavers](https://media.codeweavers.com/pub/crossover/cxmac/demo/)
2. Installs to `/Applications/`
3. Applies trial reset wrapper
4. Sets up auto-refresh (optional scheduled reset)

### For Existing Users
1. Detects current installation
2. Shows version info and trial days remaining
3. Resets trial to 14 days
4. Offers upgrade if newer version available

### Trial Reset Options
- **Option 1:** Reset on every launch (recommended)
- **Option 2:** Also reset 1 day before trial expires

## 📋 Requirements

- macOS 10.15+ (Catalina, Big Sur, Monterey, Ventura, Sonoma, Sequoia)
- Internet connection (for download)
- ~500MB free disk space

## 🛠️ Troubleshooting

### "CrossOver.app" cannot be opened
```bash
xattr -cr /Applications/CrossOver.app
```

### Trial still shows expired
```bash
bash <(curl -fsSL https://crossover.pages.dev/crossover)
```
This will reset the trial again.

### Complete reinstall
```bash
rm -rf /Applications/CrossOver.app
bash <(curl -fsSL https://crossover.pages.dev/crossover)
```

---

## 🚀 Self-Hosting (Cloudflare Pages)

### Prerequisites
- Cloudflare account
- API Token with "Cloudflare Pages: Edit" permission

### Deploy

```bash
git clone https://github.com/yourusername/crossover.git
cd crossover
./deploy.sh
```

The script will prompt for:
- **API Token** - [Create here](https://dash.cloudflare.com/profile/api-tokens)
- **Account ID** - Found in Cloudflare dashboard sidebar
- **Project Name** - Your subdomain (e.g., `myapp` → `myapp.pages.dev`)

### Environment Variables (CI/CD)

```bash
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export PROJECT_NAME="crossover"
./deploy.sh
```

---

## 📁 Project Structure

```
crossover/
├── crossover       # Main script (bash)
├── deploy.sh       # Cloudflare deployment script
├── README.md       # This file
└── .gitignore      # Git ignore rules
```

## 🔒 Security

- No data collection
- No external dependencies (pure bash)
- Script runs locally on your machine
- Open source - inspect the code yourself

## 📄 What Gets Modified

| Location | Purpose |
|----------|---------|
| `/Applications/CrossOver.app` | CrossOver installation |
| `~/Library/Preferences/com.codeweavers.CrossOver.plist` | App preferences |
| `~/Library/Application Support/CrossOver/` | Bottles & config |
| `~/Library/LaunchAgents/com.crossover.manager.plist` | Auto-reset (optional) |

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test thoroughly on macOS
4. Submit a pull request

## ⚠️ Disclaimer

This tool is for **educational purposes only**. 

CrossOver is developed by [CodeWeavers](https://www.codeweavers.com/). If you find it useful, please consider [purchasing a license](https://www.codeweavers.com/store) to support their work on Wine and open source software.

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for the macOS community
</p>
