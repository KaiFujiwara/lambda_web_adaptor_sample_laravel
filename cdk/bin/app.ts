#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { LambdaLaravelStack } from '../lib/lambda-laravel-stack';

const app = new cdk.App();

// 環境変数からアカウントIDとリージョンを取得
const account = process.env.CDK_DEFAULT_ACCOUNT;
const region = process.env.CDK_DEFAULT_REGION || 'ap-northeast-1';

if (!account) {
  throw new Error('CDK_DEFAULT_ACCOUNT environment variable is required');
}

new LambdaLaravelStack(app, 'LambdaLaravelStack', {
  env: { 
    account: account,
    region: region
  },
  description: 'Laravel Lambda Application Stack',
});

app.synth(); 