FROM php:8.3-apache

# Lambda Web Adaptorをインストール
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.5.0 /lambda-adapter /opt/extensions/lambda-adapter

# 必要なPHP拡張機能とツールをインストール
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring xml

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apache設定
RUN a2enmod rewrite
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf
COPY docker/apache-config.conf /etc/apache2/sites-available/000-default.conf

# エントリーポイントスクリプトの追加
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 環境変数の設定
ENV PORT=8080

ENTRYPOINT ["entrypoint.sh"]
