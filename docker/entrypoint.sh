#!/bin/bash

# 作業ディレクトリの作成と移動
cd /work/web

# Start PHP Built-in Server
php artisan serve --host=0.0.0.0 --port=8080