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

// スタック名を環境変数から取得するか、デフォルト値を使用
const stackName = process.env.CDK_STACK_NAME || 'LambdaLaravelStack';

// スタックの作成
const stack = new LambdaLaravelStack(app, stackName, {
  env: { 
    account: account,
    region: region
  },
  description: 'Laravel Lambda Application Stack',
  // スタック名を明示的に設定
  stackName: stackName
});

// スタックのタグを追加
cdk.Tags.of(stack).add('Environment', 'Development');
cdk.Tags.of(stack).add('Project', 'LaravelLambda');

app.synth(); 
