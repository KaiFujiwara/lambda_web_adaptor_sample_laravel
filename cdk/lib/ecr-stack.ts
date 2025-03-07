import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ecr from 'aws-cdk-lib/aws-ecr';

export class EcrStack extends cdk.Stack {
  public readonly repository: ecr.Repository;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ECRリポジトリの作成
    this.repository = new ecr.Repository(this, 'LaravelLambdaRepo', {
      repositoryName: 'laravel-lambda',
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Lambdaからのプル権限を追加
    this.repository.addToResourcePolicy(new cdk.aws_iam.PolicyStatement({
      effect: cdk.aws_iam.Effect.ALLOW,
      principals: [new cdk.aws_iam.ServicePrincipal('lambda.amazonaws.com')],
      actions: [
        'ecr:BatchCheckLayerAvailability',
        'ecr:BatchGetImage',
        'ecr:GetDownloadUrlForLayer'
      ]
    }));
  }
} 