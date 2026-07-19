#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { AqiMeStack } from '../lib/aqi-me-stack';

const app = new cdk.App();

new AqiMeStack(app, 'AqiMeStack', {
  // CloudFront ACM certificates must live in us-east-1; keeping the whole stack
  // there avoids any cross-region wiring. Account comes from the caller's creds.
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: 'us-east-1',
  },
  domainName: 'aqi-me.anystupididea.com',
  zoneName: 'anystupididea.com',
  description: 'AQI.me — static Flutter Web app on S3 + CloudFront + Route53',
});
