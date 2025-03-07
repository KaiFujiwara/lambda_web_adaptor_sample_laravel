FROM php:8.3-fpm-alpine3.18

# 必要なPHP拡張機能のインストール
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    $PHPIZE_DEPS \
&& docker-php-ext-install pdo_mysql zip

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ワーキングディレクトリを設定
WORKDIR /work/web

# アプリケーションのコピー
COPY ./src /work/web
COPY ./src/.env.example /work/web/.env

# 依存関係のインストール
RUN composer install --no-dev --optimize-autoloader

# 環境設定ファイルの準備
RUN php artisan key:generate

# 必要なディレクトリの権限設定
RUN chmod -R 777 storage bootstrap/cache

EXPOSE 8080

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
