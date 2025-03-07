#!/bin/bash

# Copy .env.example if .env doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Start Apache
apache2-foreground 