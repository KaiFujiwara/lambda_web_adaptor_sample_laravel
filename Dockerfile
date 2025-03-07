FROM php:8.3-cli

# 必要なPHP拡張機能のインストール
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
&& docker-php-ext-install pdo_mysql zip

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# アプリケーションのコピー
WORKDIR /var/task
COPY src/ .

# 依存関係のインストール
RUN composer install --no-dev --optimize-autoloader

# 環境設定ファイルの準備
COPY src/.env.example .env
RUN php artisan key:generate

# PHP設定の調整
RUN echo "display_errors=1" >> /usr/local/etc/php/php.ini && \
    echo "log_errors=1" >> /usr/local/etc/php/php.ini && \
    echo "error_log=/dev/stderr" >> /usr/local/etc/php/php.ini

# 必要なディレクトリの権限設定
RUN chmod -R 777 storage bootstrap/cache

# エントリーポイントの設定
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
