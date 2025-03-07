import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as path from 'path';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';

interface LambdaLaravelStackProps extends cdk.StackProps {
  repository: ecr.Repository;
}

export class LambdaLaravelStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: LambdaLaravelStackProps) {
    super(scope, id, props);

    // アプリケーションの環境変数を Secrets Manager で管理
    const appSecrets = new secretsmanager.Secret(this, 'LaravelAppSecrets', {
      secretName: 'laravel-app-secrets',
      description: 'Secrets for Laravel Lambda application',
    });

    // Lambda関数の作成
    const laravelFunction = new lambda.DockerImageFunction(this, 'LaravelFunction', {
      functionName: 'laravel-function',
      code: lambda.DockerImageCode.fromEcr(props.repository, {
        tagOrDigest: 'latest',
      }),
      memorySize: 1024,
      timeout: cdk.Duration.seconds(29),
      environment: {
        SECRETS_ARN: appSecrets.secretArn,
      },
      // 初期デプロイ時のイメージチェックをスキップ
      skipValidation: true,
      // 初期デプロイ時のダミーイメージを指定
      imageConfig: {
        entryPoint: ['/bin/sh', '-c'],
        command: ['echo "Placeholder image"'],
      }
    });
    
    // Lambda関数URLの作成
    const functionUrl = laravelFunction.addFunctionUrl({
      authType: lambda.FunctionUrlAuthType.NONE,
      cors: {
        allowedOrigins: ['*'],
        allowedMethods: [lambda.HttpMethod.ALL],
        allowedHeaders: ['*'],
      },
    });
    
    // 出力値の定義
    new cdk.CfnOutput(this, 'FunctionUrl', {
      value: functionUrl.url,
      description: 'URL of the Lambda function',
    });
    
    new cdk.CfnOutput(this, 'ECRRepositoryUri', {
      value: props.repository.repositoryUri,
      description: 'URI of the ECR repository',
    });

    // シークレットへのアクセス権限をLambda関数に付与
    appSecrets.grantRead(laravelFunction);

    // ECRへのプル権限を追加
    props.repository.grantPull(laravelFunction);

    // スタックの出力を強制的に表示
    new cdk.CfnOutput(this, 'StackName', {
      value: this.stackName,
      description: 'Stack name',
    });

    new cdk.CfnOutput(this, 'Region', {
      value: this.region,
      description: 'Stack region',
    });

    new cdk.CfnOutput(this, 'Account', {
      value: this.account,
      description: 'Stack account',
    });
  }
} 