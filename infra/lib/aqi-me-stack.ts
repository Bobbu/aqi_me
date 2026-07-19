import * as path from 'path';
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3deploy from 'aws-cdk-lib/aws-s3-deployment';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as route53 from 'aws-cdk-lib/aws-route53';
import * as targets from 'aws-cdk-lib/aws-route53-targets';

export interface AqiMeStackProps extends cdk.StackProps {
  /** Fully-qualified site domain, e.g. aqi-me.anystupididea.com. */
  readonly domainName: string;
  /** Existing Route53 hosted zone apex, e.g. anystupididea.com. */
  readonly zoneName: string;
}

/**
 * Everything AQI.me needs to be live at its custom domain, from scorched earth:
 * a private S3 bucket, a CloudFront distribution (OAC) with SPA rewrites, an
 * ACM certificate, and the Route53 alias records. `cdk deploy` builds it all;
 * `cdk destroy` removes it (leaving the shared apex zone intact). No secrets.
 */
export class AqiMeStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: AqiMeStackProps) {
    super(scope, id, props);

    const { domainName, zoneName } = props;

    // The apex zone already exists in this account (looked up, not created).
    const zone = route53.HostedZone.fromLookup(this, 'Zone', {
      domainName: zoneName,
    });

    // TLS certificate for the subdomain. This stack is us-east-1, which is where
    // CloudFront requires its viewer certificate to live.
    const certificate = new acm.Certificate(this, 'Certificate', {
      domainName,
      validation: acm.CertificateValidation.fromDns(zone),
    });

    // Private bucket for the built web bundle — only CloudFront (via OAC) reads it.
    const bucket = new s3.Bucket(this, 'SiteBucket', {
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      // Scorched-earth: destroying the stack empties and removes the bucket.
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    const distribution = new cloudfront.Distribution(this, 'Distribution', {
      comment: 'AQI.me',
      defaultRootObject: 'index.html',
      domainNames: [domainName],
      certificate,
      priceClass: cloudfront.PriceClass.PRICE_CLASS_100,
      httpVersion: cloudfront.HttpVersion.HTTP2_AND_3,
      minimumProtocolVersion: cloudfront.SecurityPolicyProtocol.TLS_V1_2_2021,
      defaultBehavior: {
        origin: origins.S3BucketOrigin.withOriginAccessControl(bucket),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
        compress: true,
      },
      // Single-page app: unknown paths (and OAC 403s) fall back to index.html.
      errorResponses: [
        {
          httpStatus: 403,
          responseHttpStatus: 200,
          responsePagePath: '/index.html',
          ttl: cdk.Duration.seconds(0),
        },
        {
          httpStatus: 404,
          responseHttpStatus: 200,
          responsePagePath: '/index.html',
          ttl: cdk.Duration.seconds(0),
        },
      ],
    });

    // The Flutter web release bundle (built via `flutter build web --release`).
    const webBundle = path.join(__dirname, '..', '..', 'build', 'web');

    // Upload everything with a long cache; prune removes files from old releases.
    const assets = new s3deploy.BucketDeployment(this, 'DeployAssets', {
      sources: [s3deploy.Source.asset(webBundle)],
      destinationBucket: bucket,
      prune: true,
      cacheControl: [
        s3deploy.CacheControl.setPublic(),
        s3deploy.CacheControl.maxAge(cdk.Duration.days(365)),
        s3deploy.CacheControl.immutable(),
      ],
    });

    // Re-upload the entry point + service worker with no-cache so a new release
    // is picked up immediately, then invalidate the edge caches. Runs after the
    // bulk upload so these headers win.
    const html = new s3deploy.BucketDeployment(this, 'DeployHtml', {
      sources: [s3deploy.Source.asset(webBundle)],
      destinationBucket: bucket,
      prune: false,
      exclude: ['*', '*/**'],
      include: ['index.html', 'flutter_service_worker.js', 'version.json'],
      cacheControl: [
        s3deploy.CacheControl.setPublic(),
        s3deploy.CacheControl.noCache(),
      ],
      distribution,
      distributionPaths: ['/*'],
    });
    html.node.addDependency(assets);

    // Point the subdomain at CloudFront (IPv4 + IPv6).
    const target = route53.RecordTarget.fromAlias(
      new targets.CloudFrontTarget(distribution),
    );
    new route53.ARecord(this, 'AliasA', {
      zone,
      recordName: domainName,
      target,
    });
    new route53.AaaaRecord(this, 'AliasAAAA', {
      zone,
      recordName: domainName,
      target,
    });

    new cdk.CfnOutput(this, 'SiteUrl', { value: `https://${domainName}` });
    new cdk.CfnOutput(this, 'DistributionId', {
      value: distribution.distributionId,
    });
    new cdk.CfnOutput(this, 'BucketName', { value: bucket.bucketName });
  }
}
