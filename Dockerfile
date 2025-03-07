FROM php:8.1.17-fpm-alpine3.17

# 必要なPHP拡張機能のインストール
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
&& docker-php-ext-install pdo_mysql zip

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ワーキングディレクトリを設定
WORKDIR /work/web

# アプリケーションのコピー
COPY ./src /work/web
RUN mv /work/web/.env.aws.lambda /work/web/.env

# 依存関係のインストール
RUN composer install --no-dev --optimize-autoloader

# 環境設定ファイルの準備
COPY src/.env.example .env
RUN php artisan key:generate

# 必要なディレクトリの権限設定
RUN chmod -R 777 storage bootstrap/cache

# エントリーポイントの設定
COPY ./docker/php/startup-lambda.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/startup-lambda.sh

EXPOSE 8080

ENTRYPOINT ["startup-lambda.sh"]


