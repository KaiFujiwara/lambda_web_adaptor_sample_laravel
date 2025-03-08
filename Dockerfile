FROM public.ecr.aws/awsguru/php:82.2023.3.11.1 AS builder
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# SQLite拡張のインストール
RUN yum install -y sqlite-devel \
    && echo "extension=pdo_sqlite.so" > /opt/php/php.d/20-pdo_sqlite.ini \
    && echo "extension=sqlite3.so" > /opt/php/php.d/20-sqlite3.ini \
    && yum clean all

COPY src /var/task/app
WORKDIR /var/task/app

RUN composer install --prefer-dist --optimize-autoloader --no-dev --no-interaction

# ストレージディレクトリの権限設定
RUN mkdir -p /var/task/app/storage/framework/{sessions,views,cache} \
    && mkdir -p /var/task/app/storage/logs \
    && mkdir -p /var/task/app/database \
    && chmod -R 777 /var/task/app/storage /var/task/app/bootstrap/cache \
    && chmod -R 777 /var/task/app/database \
    && touch /var/task/app/database/database.sqlite \
    && chmod 666 /var/task/app/database/database.sqlite

FROM public.ecr.aws/awsguru/php:82.2023.3.11.1
# SQLite拡張のインストール
RUN yum install -y sqlite-devel \
    && echo "extension=pdo_sqlite.so" > /opt/php/php.d/20-pdo_sqlite.ini \
    && echo "extension=sqlite3.so" > /opt/php/php.d/20-sqlite3.ini \
    && yum clean all

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.0 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /var/task /var/task

# config files
ADD docker/nginx.conf          /opt/nginx/conf/nginx.conf
ADD docker/php/php.ini         /opt/php/php.ini
ADD docker/php/etc/php-fpm.conf /opt/php/etc/php-fpm.conf
ADD docker/php/php.d/extensions.ini /opt/php/php.d/extensions.ini

# 設定ファイルのパスの修正（存在しない場合）
RUN if [ ! -f /opt/nginx/conf/mime.types ]; then \
        mkdir -p /opt/nginx/conf && \
        cp -n /etc/nginx/mime.types /opt/nginx/conf/ 2>/dev/null || echo "Mime types not found"; \
    fi

COPY bootstrap /opt/bootstrap
RUN chmod +x /opt/bootstrap

# 実行環境でもストレージディレクトリの権限を設定
RUN chmod -R 777 /var/task/app/storage /var/task/app/bootstrap/cache \
    && chmod -R 777 /var/task/app/database

ENTRYPOINT ["/opt/bootstrap"]