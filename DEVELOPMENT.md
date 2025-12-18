# Development Guide

## Project Structure

```
crossover/
├── crossover                    # Main script
├── deploy.sh                    # Manual Cloudflare deployment
├── README.md                    # User documentation
├── DEVELOPMENT.md               # This file
├── LICENSE                      # MIT License
├── .gitignore
└── .github/
    └── workflows/
        └── ci.yml               # CI/CD pipeline
```

## CI/CD Pipeline

The GitHub Actions workflow (`ci.yml`) runs on every push and PR:

### Jobs

| Job | Description |
|-----|-------------|
| `lint` | ShellCheck + bash syntax validation |
| `test` | Runs on macOS, tests help command and version detection |
| `deploy` | Auto-deploys to Cloudflare Pages on main branch |

### Required Secrets & Variables

Set these in GitHub repo settings → Secrets and variables → Actions:

**Secrets:**
| Secret | Description |
|--------|-------------|
| `CLOUDFLARE_API_TOKEN` | API token with "Cloudflare Pages: Edit" permission |
| `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID |

**Variables (optional):**
| Variable | Default | Description |
|----------|---------|-------------|
| `CLOUDFLARE_PROJECT_NAME` | `crossover-trial` | Cloudflare Pages project name |

### Creating Cloudflare API Token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use template "Edit Cloudflare Workers" or create custom:
   - **Permissions:** Account → Cloudflare Pages → Edit
   - **Account Resources:** Include → Your Account
4. Copy the token and add as `CLOUDFLARE_API_TOKEN` secret

### Finding Account ID

1. Go to https://dash.cloudflare.com
2. Look in the right sidebar under "Account ID"
3. Add as `CLOUDFLARE_ACCOUNT_ID` secret

## Manual Deployment

If you prefer manual deployment:

```bash
./deploy.sh
```

This will prompt for credentials and deploy to Cloudflare Pages.

## Local Testing

```bash
# Test syntax
bash -n crossover

# Test help command
./crossover help

# Test on existing CrossOver installation
./crossover

# Test removal (careful!)
./crossover remove
```

## Script Architecture

### Main Functions

| Function | Purpose |
|----------|---------|
| `cmd_install` | Main install flow |
| `cmd_remove` | Uninstall flow |
| `find_app` | Locate CrossOver.app |
| `get_latest` | Fetch latest version from CodeWeavers |
| `download_and_install` | Download and install CrossOver |
| `reset_trial` | Reset trial data |
| `apply_crack` | Apply launcher wrapper |
| `setup_auto_reset` | Configure scheduled reset |

### Trial Reset Mechanism

1. **Wrapper Script:** Replaces `CrossOver` binary with a bash script that:
   - Deletes `~/Library/Application Support/CrossOver/tie/`
   - Resets `FirstRunDate` in preferences
   - Launches original binary (`CrossOver.bin`)

2. **Scheduled Reset (optional):** LaunchAgent that runs reset before trial expires

### Data Locations

| Path | Content |
|------|---------|
| `/Applications/CrossOver.app` | Application |
| `~/Library/Preferences/com.codeweavers.CrossOver.plist` | Preferences |
| `~/Library/Application Support/CrossOver/` | Bottles, config |
| `~/Library/Application Support/CrossOver/tie/` | Trial license data |
| `~/Library/LaunchAgents/com.crossover.manager.plist` | Auto-reset service |

## Version Updates

CrossOver versions are fetched dynamically from:
```
https://media.codeweavers.com/pub/crossover/cxmac/demo/?C=M;O=D
```

The script parses this directory listing for `crossover-X.X.X.zip` files.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Test on macOS
5. Submit PR

PRs trigger the CI pipeline for validation before merge.

## Release Process

1. Merge PR to `main`
2. CI automatically:
   - Runs lint and tests
   - Deploys to Cloudflare Pages
3. Changes are live at `https://crossover-trial.pages.dev`

