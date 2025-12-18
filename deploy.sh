#!/usr/bin/env bash
#
# Deploy to Cloudflare Pages
#
# Usage:
#   ./deploy.sh                    # Interactive setup
#   ./deploy.sh --token <token>    # With API token
#
# Environment variables:
#   CLOUDFLARE_API_TOKEN    - Your Cloudflare API token
#   CLOUDFLARE_ACCOUNT_ID   - Your Cloudflare account ID
#   PROJECT_NAME            - Cloudflare Pages project name (default: crossover)
#

set -euo pipefail

# Colors
# shellcheck disable=SC2034
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' N='\033[0m' BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.deploy-config"
DIST_DIR="$SCRIPT_DIR/dist"

# ─────────────────────────────────────────────────────────────────────────────

log()   { echo -e "${G}✓${N} $1"; }
warn()  { echo -e "${Y}!${N} $1"; }
error() { echo -e "${R}✗${N} $1"; exit 1; }
info()  { echo -e "${C}→${N} $1"; }

# ─────────────────────────────────────────────────────────────────────────────

load_config() {
    # shellcheck source=/dev/null
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID"
PROJECT_NAME="$PROJECT_NAME"
EOF
    chmod 600 "$CONFIG_FILE"
}

setup_interactive() {
    echo -e "${BOLD}Cloudflare Deployment Setup${N}"
    echo ""
    
    # API Token
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
        echo "Create an API token at: https://dash.cloudflare.com/profile/api-tokens"
        echo "Required permissions: Cloudflare Pages (Edit)"
        echo ""
        read -rsp "Enter Cloudflare API Token: " CLOUDFLARE_API_TOKEN
        echo ""
    fi
    
    # Account ID
    if [[ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]]; then
        echo ""
        echo "Find your Account ID at: https://dash.cloudflare.com (right sidebar)"
        read -rp "Enter Cloudflare Account ID: " CLOUDFLARE_ACCOUNT_ID
    fi
    
    # Project Name
    if [[ -z "${PROJECT_NAME:-}" ]]; then
        read -rp "Enter project name [crossover]: " PROJECT_NAME
        PROJECT_NAME="${PROJECT_NAME:-crossover}"
    fi
    
    save_config
    echo ""
}

verify_token() {
    info "Verifying API token..."
    
    local response
    response=$(curl -sf -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" 2>/dev/null) || error "Invalid API token"
    
    if ! echo "$response" | grep -q '"success":true'; then
        error "API token verification failed"
    fi
    
    log "API token valid"
}

build_dist() {
    info "Building distribution..."
    
    rm -rf "$DIST_DIR"
    mkdir -p "$DIST_DIR"
    
    # Copy main script
    cp "$SCRIPT_DIR/crossover" "$DIST_DIR/crossover"
    
    # Create index.html with redirect/instructions
    cat > "$DIST_DIR/index.html" << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CrossOver Manager</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
        }
        .container {
            max-width: 600px;
            padding: 2rem;
            text-align: center;
        }
        h1 { 
            font-size: 3rem;
            margin-bottom: 0.5rem;
        }
        .subtitle {
            color: #888;
            margin-bottom: 2rem;
        }
        .code-block {
            background: #0d1117;
            border: 1px solid #30363d;
            border-radius: 8px;
            padding: 1rem;
            margin: 1rem 0;
            text-align: left;
            position: relative;
        }
        code {
            font-family: 'SF Mono', Monaco, monospace;
            font-size: 0.9rem;
            color: #58a6ff;
        }
        .label {
            color: #8b949e;
            font-size: 0.75rem;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }
        .copy-btn {
            position: absolute;
            right: 0.5rem;
            top: 0.5rem;
            background: #21262d;
            border: 1px solid #30363d;
            color: #8b949e;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.75rem;
        }
        .copy-btn:hover { background: #30363d; color: #fff; }
        .features {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 2rem;
            text-align: left;
        }
        .feature {
            background: rgba(255,255,255,0.05);
            padding: 1rem;
            border-radius: 8px;
        }
        .feature h3 { font-size: 0.9rem; margin-bottom: 0.25rem; }
        .feature p { font-size: 0.8rem; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🍷</h1>
        <h1>CrossOver Manager</h1>
        <p class="subtitle">Unlimited trial with one command</p>
        
        <div class="code-block">
            <div class="label">Install</div>
            <code id="install-cmd">bash &lt;(curl -fsSL DEPLOY_URL/crossover)</code>
            <button class="copy-btn" onclick="copy('install-cmd')">Copy</button>
        </div>
        
        <div class="code-block">
            <div class="label">Remove</div>
            <code id="remove-cmd">bash &lt;(curl -fsSL DEPLOY_URL/crossover) remove</code>
            <button class="copy-btn" onclick="copy('remove-cmd')">Copy</button>
        </div>
        
        <div class="features">
            <div class="feature">
                <h3>⚡ One Command</h3>
                <p>Downloads, installs, and cracks automatically</p>
            </div>
            <div class="feature">
                <h3>🔄 Auto Reset</h3>
                <p>Trial resets every time you launch</p>
            </div>
            <div class="feature">
                <h3>📦 Smart Download</h3>
                <p>Detects existing installers</p>
            </div>
            <div class="feature">
                <h3>🧹 Clean Remove</h3>
                <p>Option to keep Windows apps</p>
            </div>
        </div>
    </div>
    
    <script>
        // Replace DEPLOY_URL with actual URL
        const url = window.location.origin;
        document.querySelectorAll('code').forEach(el => {
            el.textContent = el.textContent.replace('DEPLOY_URL', url);
        });
        
        function copy(id) {
            const text = document.getElementById(id).textContent;
            navigator.clipboard.writeText(text);
            event.target.textContent = 'Copied!';
            setTimeout(() => event.target.textContent = 'Copy', 1500);
        }
    </script>
</body>
</html>
HTML
    
    log "Built dist/ directory"
}

create_project() {
    info "Checking if project exists..."
    
    local response
    response=$(curl -sf -X GET \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" 2>/dev/null) || response=""
    
    if echo "$response" | grep -q '"success":true'; then
        log "Project '$PROJECT_NAME' exists"
        return 0
    fi
    
    info "Creating project '$PROJECT_NAME'..."
    
    response=$(curl -sf -X POST \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$PROJECT_NAME\",\"production_branch\":\"main\"}" 2>/dev/null) || error "Failed to create project"
    
    if ! echo "$response" | grep -q '"success":true'; then
        error "Failed to create project: $response"
    fi
    
    log "Created project '$PROJECT_NAME'"
}

deploy() {
    info "Deploying to Cloudflare Pages..."
    
    # Create deployment using direct upload
    # First, get upload URL
    local response
    response=$(curl -sf -X POST \
        "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -F "manifest=" 2>/dev/null) || true
    
    # Use wrangler if available, otherwise use API
    if command -v wrangler &>/dev/null; then
        info "Using Wrangler CLI..."
        cd "$DIST_DIR"
        CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" wrangler pages deploy . \
            --project-name="$PROJECT_NAME" \
            --commit-dirty=true \
            --branch=main 2>/dev/null || error "Deployment failed"
    else
        # Manual upload via API
        info "Uploading files..."
        
        # Create a tarball
        local tarball="/tmp/deploy-$$.tar.gz"
        tar -czf "$tarball" -C "$DIST_DIR" .
        
        # Upload using the Pages API
        response=$(curl -sf -X POST \
            "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -F "branch=main" \
            -F "files=@$tarball" 2>/dev/null) || {
            rm -f "$tarball"
            warn "Direct API upload may require Wrangler CLI"
            info "Install with: npm install -g wrangler"
            info "Then run: ./deploy.sh"
            exit 1
        }
        
        rm -f "$tarball"
    fi
    
    log "Deployment successful!"
    echo ""
    echo -e "${BOLD}Your site is live at:${N}"
    echo -e "${C}  https://${PROJECT_NAME}.pages.dev${N}"
    echo ""
    echo -e "${BOLD}Install command:${N}"
    echo -e "${C}  bash <(curl -fsSL https://${PROJECT_NAME}.pages.dev/crossover)${N}"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}🚀 Cloudflare Pages Deployment${N}"
    echo ""
    
    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --token) CLOUDFLARE_API_TOKEN="$2"; shift 2 ;;
            --account) CLOUDFLARE_ACCOUNT_ID="$2"; shift 2 ;;
            --project) PROJECT_NAME="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    # Load saved config
    load_config
    
    # Set defaults
    PROJECT_NAME="${PROJECT_NAME:-crossover}"
    
    # Interactive setup if needed
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]] || [[ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]]; then
        setup_interactive
    fi
    
    verify_token
    build_dist
    create_project
    deploy
}

main "$@"

