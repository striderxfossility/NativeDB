## Config Example .env must create

```
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost
APP_TESTS = false

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
```

### Gmail Optional
```
GOOGLE_PROJECT_ID=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=
GOOGLE_ALLOW_MULTIPLE_CREDENTIALS=true
GOOGLE_ALLOW_JSON_ENCRYPT=true
```

### Model Cache Optional
```
MODEL_CACHE_ENABLED=false
```

### Telescope Optional
```
TELESCOPE_ENABLED=false
```


## Starting

``composer install``

``npm install``

``npm run dev``

``php artisan key:generate``

``php artisan migrate:fresh --seed``

## Testing

``php artisan test``

## Server

``php artisan serve``

``php artisan queue:work``

## URL

``http://127.0.0.1:8000/register``

``http://127.0.0.1:8000/login``

