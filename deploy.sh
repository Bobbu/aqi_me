#!/usr/bin/env bash
# One-click deploy for AQI.me: build the Flutter web bundle, then deploy the CDK
# stack (S3 + CloudFront + Route53 + ACM) to aqi-me.anystupididea.com.
#
# Prereqs: Flutter, Node, AWS creds for the target account, and a one-time
# `cdk bootstrap` in us-east-1 (already done for this account).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Building Flutter web (release)"
cd "$ROOT"
# --pwa-strategy=none: no service worker. Combined with no-cache entry files
# (see infra), this makes new deploys apply on a single reload — no SW-cache
# staleness. (This app needs the network anyway, so offline caching is moot.)
# --no-tree-shake-icons: ship the full (stable) Material icon font instead of a
# per-build subset, so newly-used icons can't go missing behind the immutable
# font cache.
flutter build web --release --pwa-strategy=none --no-tree-shake-icons

echo "==> Deploying CDK stack"
cd "$ROOT/infra"
if [ ! -d node_modules ]; then
  npm ci
fi
npx cdk deploy --require-approval never

echo "==> Done. Live at https://aqi-me.anystupididea.com"
