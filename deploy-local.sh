#!/bin/bash
# deploy-local.sh
# Full local deploy in correct order
# Usage: ./deploy-local.sh [apply|destroy|plan]

set -euo pipefail

ACTION="${1:-apply}"

# ── Auth ──────────────────────────────────────────────────────
export ARM_USE_OIDC=false
export ARM_USE_AZURE_CLI_AUTH=true
export ARM_TENANT_ID="YOUR_TENANT_ID"
export ARM_SUBSCRIPTION_ID="YOUR_PLATFORM_SUBSCRIPTION_ID"

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

# ── Prereq check ─────────────────────────────────────────────
az account show > /dev/null 2>&1 || fail "Not logged in. Run: az login"
ok "Logged in as: $(az account show --query user.name -o tsv)"

# ── Deploy order ─────────────────────────────────────────────
LAYERS=(
  "shared/03-management"
  "shared/04-hub"
  "dev/01-management-groups"
  "dev/02-policy"
  "dev/05-workload"
  "shared/05-avnm"
)

# Destroy runs in reverse
if [ "$ACTION" = "destroy" ]; then
  LAYERS=(
    "shared/05-avnm"
    "dev/05-workload"
    "dev/02-policy"
    "dev/01-management-groups"
    "shared/04-hub"
    "shared/03-management"
  )
fi

TOTAL=${#LAYERS[@]}
PASSED=0
FAILED=()

for i in "${!LAYERS[@]}"; do
  LAYER="${LAYERS[$i]}"
  NUM=$((i + 1))
  log "[$NUM/$TOTAL] $ACTION → $LAYER"

  if ./local-test.sh "$LAYER" "$ACTION"; then
    ok "[$NUM/$TOTAL] $LAYER complete"
    PASSED=$((PASSED + 1))
  else
    FAILED+=("$LAYER")
    fail "[$NUM/$TOTAL] $LAYER FAILED — stopping"
  fi
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Done: $PASSED/$TOTAL layers completed"
