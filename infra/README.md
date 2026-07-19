# AQI.me — Infrastructure (AWS CDK)

One CDK stack that hosts the app at **https://aqi-me.anystupididea.com** from
scorched earth: private S3 bucket, CloudFront (Origin Access Control) with SPA
rewrites, an ACM certificate, and Route53 alias records. No secrets, no console.

Everything lives in **us-east-1** (required for the CloudFront certificate).

## Prerequisites

- Node 18+ and AWS credentials for the target account.
- The `anystupididea.com` hosted zone in this account's Route53 (looked up, not
  created).
- A one-time `cdk bootstrap aws://<account>/us-east-1` (already done here).
- The built web bundle at `../build/web` (`flutter build web --release`).

## Deploy

From the repo root, the one-click path:

```bash
./deploy.sh
```

That builds the Flutter web release and runs `cdk deploy`. Or manually:

```bash
flutter build web --release        # from repo root
cd infra
npm ci
npx cdk deploy
```

First deploy takes a few minutes (CloudFront + DNS-validated certificate).

## Useful commands

| Command | What it does |
|---------|--------------|
| `npm run diff` | Show changes vs. the deployed stack |
| `npm run synth` | Synthesize the CloudFormation template |
| `npm run typecheck` | Type-check the stack without deploying |
| `npm run destroy` | Tear it all down (bucket auto-empties; apex zone is left intact) |

## How releases stay fresh

Static assets are uploaded with a one-year immutable cache. `index.html` and the
Flutter service worker are re-uploaded with `no-cache`, and every deploy
invalidates the CloudFront cache (`/*`) — so a new release goes live immediately.
