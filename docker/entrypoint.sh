#!/bin/bash

# 環境変数の設定
export APACHE_RUN_USER=apache
export APACHE_RUN_GROUP=apache
export APACHE_PID_FILE=/var/run/apache2/apache2.pid
export APACHE_RUN_DIR=/var/run/apache2
export APACHE_LOCK_DIR=/var/lock/apache2
export APACHE_LOG_DIR=/var/log/apache2

# 必要なディレクトリの作成
mkdir -p /var/run/apache2 /var/lock/apache2 /var/log/apache2

# Laravel関連の初期化
cd /var/task
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Apacheの起動
httpd -D FOREGROUND &

# Lambda Web Adapterの起動
exec /usr/local/bin/aws-lambda-web-adapter 