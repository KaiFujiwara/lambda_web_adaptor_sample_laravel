import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as path from 'path';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';

export class LambdaLaravelStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ECRリポジトリの作成
    const repository = new ecr.Repository(this, 'LaravelLambdaRepo', {
      repositoryName: 'laravel-lambda',
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Docker イメージのビルドパスを指定
    const dockerFilePath = path.join(__dirname, '../../');
    
    // アプリケーションの環境変数を Secrets Manager で管理
    const appSecrets = new secretsmanager.Secret(this, 'LaravelAppSecrets', {
      secretName: 'laravel-app-secrets',
      description: 'Secrets for Laravel Lambda application',
    });

    // Lambda関数の作成
    const laravelFunction = new lambda.DockerImageFunction(this, 'LaravelFunction', {
      functionName: 'laravel-function',
      code: lambda.DockerImageCode.fromEcr(repository),
      memorySize: 1024,
      timeout: cdk.Duration.seconds(29),
      environment: {
        APP_KEY: appSecrets.secretValueFromJson('APP_KEY').toString(),
        // 必要に応じて他の環境変数を追加
      },
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
      value: repository.repositoryUri,
      description: 'URI of the ECR repository',
    });

    // シークレットへのアクセス権限をLambda関数に付与
    appSecrets.grantRead(laravelFunction);
  }
} 