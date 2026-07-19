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
flutter build web --release

echo "==> Deploying CDK stack"
cd "$ROOT/infra"
if [ ! -d node_modules ]; then
  npm ci
fi
npx cdk deploy --require-approval never

echo "==> Done. Live at https://aqi-me.anystupididea.com"
