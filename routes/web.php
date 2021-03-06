<?php

use Illuminate\Support\Facades\Route;

use Rap2hpoutre\LaravelLogViewer\LogViewerController;
use App\Http\Controllers\TypeController;
use App\Http\Controllers\EnumController;
use App\Http\Controllers\BitfieldController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\CodeController;
use App\Http\Controllers\TweakController;
use App\Models\TweakGroup;
use App\Models\TweakValue;

Route::view('/', 'welcome');
Route::view('/dashboard', 'welcome');

Route::get('/test', function() {
    
});

Broadcast::routes();

Route::post('search',                   [SearchController::class, 'search'])->name('search');
Route::get('search/{type}/access',      [SearchController::class, 'access'])->name('search.access');

Route::get('scripts',                   [CodeController::class, "index"])->name('codes.index');
Route::get('codes/{code}/show',         [CodeController::class, "show"])->name('codes.show');

Route::get('tweakdb',                   [TweakController::class, "index"])->name('tweakdb.all');
Route::get('tweakdb/{tweakGroup}/show', [TweakController::class, "show"])->name('tweakdb.show');

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
