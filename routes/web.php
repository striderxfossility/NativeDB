<?php

use Illuminate\Support\Facades\Route;

use Rap2hpoutre\LaravelLogViewer\LogViewerController;
use App\Http\Controllers\TypeController;
use App\Http\Controllers\EnumController;
use App\Http\Controllers\BitfieldController;
use App\Http\Controllers\SearchController;

Route::view('/', 'welcome');

Broadcast::routes();

Route::post('search',                   [SearchController::class, 'search'])->name('search');

Route::get('classes',                   [TypeController::class, "index"])->name('types.all');
Route::get('classes/{type}/show',       [TypeController::class, "show"])->name('types.show');

Route::get('enums',                     [EnumController::class, "index"])->name('enums.all');
Route::get('enums/{enum}/show',         [EnumController::class, "show"])->name('enums.show');

Route::get('bitfields',                 [BitfieldController::class, "index"])->name('bitfields.all');
Route::get('bitfields/{bitfield}/show', [BitfieldController::class, "show"])->name('bitfields.show');

Route::middleware(['auth'])->group(function () 
{
    Route::prefix('jobs')->group(function () {
        Route::queueMonitor();
    });
    
    Route::get('logs',      [LogViewerController::class,    'index']);
});

require __DIR__.'/channels.php';
