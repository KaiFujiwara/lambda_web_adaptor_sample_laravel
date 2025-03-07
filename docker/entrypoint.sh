#!/bin/bash

# Copy .env.example if .env doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# ストレージディレクトリの権限を設定
chmod -R 777 storage bootstrap/cache

# Start Apache
apache2-foreground 