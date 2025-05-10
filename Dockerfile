# ---------- build stage ----------
FROM public.ecr.aws/docker/library/php:8.3-cli-alpine AS build
RUN apk add --no-cache git unzip oniguruma-dev \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
WORKDIR /var/task
COPY src/ .

# lambdaはtmp以外に書き込めないので、書き込み先を変更
RUN cp .env.example .env \
&& sed -i 's/^SESSION_DRIVER=.*/SESSION_DRIVER=cookie/' .env \
&& sed -i 's/^LOG_CHANNEL=.*/LOG_CHANNEL=stderr/' .env \
&& composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
&& php artisan key:generate --ansi \
&& php artisan optimize

# ---------- runtime --------------
FROM public.ecr.aws/docker/library/php:8.3-cli-alpine
# Lambda Web Adapter
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 \
        /lambda-adapter /opt/extensions/lambda-adapter
# アプリ本体
COPY --from=build /var/task /var/task
WORKDIR /var/task

EXPOSE 8080
CMD ["php", "-d", "variables_order=EGPCS", "-S", "0.0.0.0:8080", "-t", "public"]
