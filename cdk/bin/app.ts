#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { LambdaLaravelStack } from '../lib/lambda-laravel-stack';

const app = new cdk.App();
new LambdaLaravelStack(app, 'LambdaLaravelStack', {
  env: { 
    account: process.env.CDK_DEFAULT_ACCOUNT, 
    region: process.env.CDK_DEFAULT_REGION || 'ap-northeast-1' 
  },
}); 