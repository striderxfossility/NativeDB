<?php

use Illuminate\Support\Facades\Route;

use Rap2hpoutre\LaravelLogViewer\LogViewerController;
use App\Http\Controllers\TypeController;
use App\Http\Controllers\EnumController;
use App\Http\Controllers\BitfieldController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\CodeController;
use App\Models\TweakGroup;
use App\Models\TweakValue;

Route::view('/', 'welcome');
Route::view('/dashboard', 'welcome');

Route::get('/test', function() {
    //if (!file_exists('public/tweakdb.json')) {
    //    dump("Cannot find tweakdb.json, upload it to public dir");
        //$this->command->error("Cannot find tweakdb.json, upload it to public dir");
    //} else {
        $string         = file_get_contents(base_path('public/tweakdb.json'));
        $string         = preg_replace('/([0-9^]+):/', '"$1":', $string);
        $string         = str_replace('\\', '/', $string);
        $arr            = json_decode($string, true);
        $amountOfFlats  = 21;
        $timestamp  = now()->toDateTimeString();

        if($arr == null) {
            //$this->command->error("tweakdb.json is not a valid json file");
            dump(json_last_error());
        } else {
            for ($i=0; $i < $amountOfFlats; $i++) { 
                foreach($arr['flat']['keys' . $i] as $key => $value)
                {
                    $groups = explode('.', $key);
                    $headGroup = 0;
                    for ($x=0; $x < count($groups) - 1; $x++) { 
                        $tweakGroup = TweakGroup::whereName($groups[$x])->whereTweakGroupId($headGroup)->first();

                        if($tweakGroup != null) {
                            $headGroup = $tweakGroup->id;
                        } else {
                            $headGroup = TweakGroup::insertGetId([
                                'tweak_group_id' => $headGroup,
                                'name'           => $groups[$x],
                                "created_at"     => $timestamp,
                                "updated_at"     => $timestamp,
                            ]);
                        }
                    }

                    $value = json_encode($arr['flat']['values' . $i][$value]);
                    $tweakValue = TweakValue::whereTweakGroupId($headGroup)->whereName($key)->whereValue($value)->first();

                    if ($tweakValue == null) {
                        TweakValue::create([
                            'tweak_group_id'    => $headGroup,
                            'name'              => $key,
                            'value'             => $value
                        ]);
                    } else {
                        $tweakValue->value = $value;
                        $tweakValue->update();
                    }
                    //dump($key);
                    //dump($arr['flat']['values' . $i][$value]);
                    
                }
            }
        }
    //}
});

Broadcast::routes();

Route::post('search',                   [SearchController::class, 'search'])->name('search');
Route::get('search/{type}/access',      [SearchController::class, 'access'])->name('search.access');

Route::get('scripts',                   [CodeController::class, "index"])->name('codes.index');
Route::get('codes/{code}/show',         [CodeController::class, "show"])->name('codes.show');

Route::get('classes',                   [TypeController::class, "index"])->name('types.all');
Route::get('classes/{type}/show',       [TypeController::class, "show"])->name('types.show');

Route::get('enums',                     [EnumController::class, "index"])->name('enums.all');
Route::get('enums/{enum}/show',         [EnumController::class, "show"])->name('enums.show');

Route::get('bitfields',                 [BitfieldController::class, "index"])->name('bitfields.all');
Route::get('bitfields/{bitfield}/show', [BitfieldController::class, "show"])->name('bitfields.show');

Route::middleware(['auth'])->group(function () 
{
    Route::get('codes/{name}/{type}/{prop}/{method}/store',     [CodeController::class, "store"])->name('codes.store');
    Route::get('codes/{code}/edit',         [CodeController::class, "edit"])->name('codes.edit');
    Route::post('codes/{code}/update',      [CodeController::class, "update"])->name('codes.update');
    Route::get('code/{type}/create',        [CodeController::class, "create"])->name('codes.create');
    Route::post('code/{type}/storeSwift',   [CodeController::class, "storeSwift"])->name('codes.storeSwift');

    Route::prefix('jobs')->group(function () {
        Route::queueMonitor();
    });
    
    Route::get('logs',      [LogViewerController::class,    'index']);
});

require __DIR__.'/channels.php';

Auth::routes();
