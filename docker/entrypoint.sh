#!/bin/bash

# 環境変数の設定
source /etc/apache2/envvars

# Apacheの起動
apache2 -D FOREGROUND &

# Laravel関連の初期化
cd /var/task
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Lambda Adapterの起動
/usr/local/bin/aws-lambda-rie /usr/local/bin/php-fpm 