import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iam from 'aws-cdk-lib/aws-iam';

export interface AqiMeCicdStackProps extends cdk.StackProps {
  /** GitHub org/user that owns the repo, e.g. "Bobbu". */
  readonly githubOwner: string;
  /** GitHub repo name, e.g. "aqi_me". */
  readonly githubRepo: string;
  /** CDK bootstrap qualifier (default "hnb659fds"). */
  readonly cdkQualifier: string;
}

/**
 * CI/CD trust: a GitHub OIDC provider and an IAM role that GitHub Actions
 * assumes (no long-lived keys) to deploy {@link AqiMeStack}. The role can only
 * assume the CDK bootstrap roles — that is all `cdk deploy` needs — so its blast
 * radius is limited to CDK deployments.
 *
 * Deployed once, out of band (`cdk deploy AqiMeCicdStack`); thereafter GitHub
 * Actions deploys the app stack on every push to main.
 */
export class AqiMeCicdStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: AqiMeCicdStackProps) {
    super(scope, id, props);

    const { githubOwner, githubRepo, cdkQualifier } = props;

    const provider = new iam.OpenIdConnectProvider(this, 'GitHubOidc', {
      url: 'https://token.actions.githubusercontent.com',
      clientIds: ['sts.amazonaws.com'],
    });

    const role = new iam.Role(this, 'GitHubDeployRole', {
      roleName: 'aqi-me-github-deploy',
      description: 'Assumed by GitHub Actions to deploy AqiMeStack via CDK',
      maxSessionDuration: cdk.Duration.hours(1),
      // AWS requires a `sub` (or `job_workflow_ref`) condition on GitHub OIDC
      // roles. This repo customizes its OIDC subject to embed numeric owner/repo
      // IDs (e.g. "repo:Bobbu@426328/aqi_me@1305205082:ref:refs/heads/main"), so
      // the sub is matched with wildcards for those IDs and pinned to main; the
      // `repository` equality nails the identity.
      assumedBy: new iam.OpenIdConnectPrincipal(provider, {
        StringEquals: {
          'token.actions.githubusercontent.com:aud': 'sts.amazonaws.com',
          'token.actions.githubusercontent.com:repository':
            `${githubOwner}/${githubRepo}`,
        },
        StringLike: {
          'token.actions.githubusercontent.com:sub':
            `repo:${githubOwner}@*/${githubRepo}@*:ref:refs/heads/main`,
        },
      }),
    });

    // The only permission needed: assume the CDK bootstrap roles (deploy,
    // file-publishing, image-publishing, lookup) for this account + region.
    role.addToPolicy(
      new iam.PolicyStatement({
        actions: ['sts:AssumeRole'],
        resources: [
          `arn:aws:iam::${this.account}:role/cdk-${cdkQualifier}-*-${this.account}-${this.region}`,
        ],
      }),
    );

    new cdk.CfnOutput(this, 'DeployRoleArn', { value: role.roleArn });
  }
}
