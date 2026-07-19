#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { AqiMeStack } from '../lib/aqi-me-stack';
import { AqiMeCicdStack } from '../lib/aqi-me-cicd-stack';

const app = new cdk.App();

const env = {
  // CloudFront ACM certificates must live in us-east-1; keeping the whole stack
  // there avoids any cross-region wiring. Account comes from the caller's creds.
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: 'us-east-1',
};

new AqiMeStack(app, 'AqiMeStack', {
  env,
  domainName: 'aqi-me.anystupididea.com',
  zoneName: 'anystupididea.com',
  description: 'AQI.me — static Flutter Web app on S3 + CloudFront + Route53',
});

// Deployed once out of band; GitHub Actions then deploys AqiMeStack on push.
new AqiMeCicdStack(app, 'AqiMeCicdStack', {
  env,
  githubOwner: 'Bobbu',
  githubRepo: 'aqi_me',
  cdkQualifier: 'hnb659fds',
  description: 'AQI.me — GitHub Actions OIDC deploy role',
});
