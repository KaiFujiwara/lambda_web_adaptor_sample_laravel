#!/bin/bash

# 作業ディレクトリの作成と移動
mkdir -p /tmp/app
cp -r /var/task/* /tmp/app/
cd /tmp/app

# Copy .env.example if .env doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# ストレージディレクトリの権限を設定
chmod -R 777 storage bootstrap/cache

# Start Apache
apache2-foreground 