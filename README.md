# Laravel Lambda Web Adapter Sample

AWS Lambda Web Adaptorを使用してLaravelアプリケーションをサーバーレスで実行するサンプルプロジェクトです。

## ローカル環境のセットアップ手順

### 1. ローカル環境設定
```bash
cd src
cp .env.example .env
php artisan key:generate
```

### 2. Dockerイメージのビルドと実行
```bash 
docker build -t laravel-lwa:latest .
docker run -p 8080:8080 laravel-lwa:latest
```

### 2. 動作確認
ブラウザで http://localhost:8080 にアクセスし、Laravelのウェルカムページが表示されることを確認します。

## AWSへのデプロイ

### 1. 事前準備
ローカル環境でAWS CLIが使える状態にしておく。

### 2. ECRリポジトリの作成
AWSのコンソール画面からECRリポジトリを作成する。
リポジトリ作成後、「プッシュコマンドを表示」より、コマンドをコピーしてローカル環境で実行する。

### 3. Lambda関数の作成
AWSのコンソール画面でLambda関数を作成する。
オプションはコンテナイメージで、2で作成したリポジトリを指定する。
作成後、設定>関数URLを有効にする。

### 4. 動作確認
3で作成した関数のURLにアクセスし、Laravelのウェルカムページが表示されることを確認する。
