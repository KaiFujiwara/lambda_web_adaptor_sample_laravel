#!/bin/bash

# 作業ディレクトリの作成と移動
mkdir -p /tmp/app
cp -r /var/task/* /tmp/app/
cd /tmp/app

# ストレージディレクトリの権限を設定
chmod -R 777 storage bootstrap/cache

# Start PHP Built-in Server
php artisan serve --host=0.0.0.0 --port=8080 