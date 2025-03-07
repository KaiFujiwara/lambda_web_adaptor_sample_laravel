# Laravel Lambda Web Adapter Sample

AWS Lambda Web Adaptorを使用してLaravelアプリケーションをサーバーレスで実行するサンプルプロジェクトです。

## ローカル環境のセットアップ手順

### 1. Dockerイメージのビルドと実行
```bash 
# イメージをビルド
docker build -t laravel-lambda .

# コンテナを起動（srcディレクトリをマウント）
docker run -d -p 8080:8080 -v $(pwd)/src:/var/www/html --name laravel-container laravel-lambda
```

### 2. 権限の設定
```bash
# ストレージディレクトリの権限を設定
docker exec -it laravel-container bash -c "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache"
docker exec -it laravel-container bash -c "chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache"
```

### 3. 動作確認
ブラウザで http://localhost:8080 にアクセスし、Laravelのウェルカムページが表示されることを確認します。

## GitHub Actionsを使った自動デプロイ

このプロジェクトは2つのGitHub Actionsワークフローを使用しています：

1. アプリケーションのデプロイ（`deploy-app.yml`）
   - `src/`ディレクトリ
   - `Dockerfile`
   - `docker/`ディレクトリ
   の変更時に実行

2. インフラのデプロイ（`deploy-infra.yml`）
   - `cdk/`ディレクトリの変更時に実行

### 1. 設定手順

1. GitHubリポジトリのSettings > Secrets and variables > Actionsに以下を設定：
   - `AWS_ACCESS_KEY_ID`: AWSのアクセスキーID
   - `AWS_SECRET_ACCESS_KEY`: AWSのシークレットアクセスキー

2. mainブランチにプッシュすると、変更されたコンポーネントに応じて自動的にデプロイが実行されます。

### 2. 動作確認
出力されたLambda関数のURLにアクセスし、Laravelのウェルカムページが表示されることを確認します。

## 注意事項
- srcディレクトリはホストマシンとコンテナ間で共有されます
- コンテナを再起動してもソースコードは保持されます
- 本番環境用の.envファイルは適切に管理し、機密情報を含む場合は暗号化するなどの対策を行ってください

