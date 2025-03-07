FROM php:8.3-apache

# 必要なPHP拡張機能のインストール
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
&& docker-php-ext-install pdo_mysql zip

# Lambdaユーザーの作成
RUN useradd -r -s /bin/false lambda

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

# 必要なディレクトリの権限設定
RUN chown -R lambda:lambda /var/task

# Apacheの設定
RUN a2enmod rewrite
COPY docker/apache-config.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
RUN sed -i 's/www-data/lambda/g' /etc/apache2/envvars

# エントリーポイントの設定
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
