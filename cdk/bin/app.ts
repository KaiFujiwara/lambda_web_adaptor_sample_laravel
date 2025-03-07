#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { LambdaLaravelStack } from '../lib/lambda-laravel-stack';

const app = new cdk.App();
new LambdaLaravelStack(app, 'LambdaLaravelStack', {
  env: { 
    account: process.env.AWS_ACCOUNT_ID,
    region: 'ap-northeast-1'
  },
  description: 'Laravel Lambda Application Stack',
});

app.synth(); 