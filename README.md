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
DB_DATABASE=dump
DB_DATABASE_SECOND=codes
DB_USERNAME=root
DB_PASSWORD=

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
```

### Model Cache Optional
```
MODEL_CACHE_ENABLED=false
```


## Starting

``create these folders under storage/framework:`` or create them

sessions
views
cache

``composer install``

``php artisan key:generate``

upload the tweakdb.json to ``public/tweakdb.json``

set php.ini: ``memory_limit = Very High ``

``php artisan migrate:fresh --seed``

OR

``php artisan migrate``

``php artisan db:seed --class=TypeSeeder`` for dump

``php artisan db:seed --class=SwiftSeeder`` for native adam smasher code

``php artisan db:seed --class=TweakSeeder`` requires tweakdb.json

The Tweakseeder requires a lot of memory limit, because of the big file (100MB). if it breaks you can run the seed again with higer limit.

if it break you can run ``php artisan up`` to put the site back online


## Server

``php artisan serve``

## URL

``http://127.0.0.1:8000/``

