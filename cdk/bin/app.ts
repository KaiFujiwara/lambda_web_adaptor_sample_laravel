#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { EcrStack } from '../lib/ecr-stack';
import { LambdaLaravelStack } from '../lib/lambda-laravel-stack';

const app = new cdk.App();

// 環境変数からアカウントIDとリージョンを取得
const account = process.env.CDK_DEFAULT_ACCOUNT;
const region = process.env.CDK_DEFAULT_REGION || 'ap-northeast-1';

if (!account) {
  throw new Error('CDK_DEFAULT_ACCOUNT environment variable is required');
}

const env = { 
  account: account,
  region: region
};

// ECRスタックを先にデプロイ
const ecrStack = new EcrStack(app, 'LaravelEcrStack', { env });

// Lambdaスタックは後でデプロイ
const lambdaStack = new LambdaLaravelStack(app, 'LambdaLaravelStack', {
  env,
  repository: ecrStack.repository
});

// 依存関係を設定
lambdaStack.addDependency(ecrStack);

// スタックのタグを追加
cdk.Tags.of(lambdaStack).add('Environment', 'Development');
cdk.Tags.of(lambdaStack).add('Project', 'LaravelLambda');

app.synth(); 

