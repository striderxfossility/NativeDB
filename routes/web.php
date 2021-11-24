<?php

use Illuminate\Support\Facades\Route;

use Rap2hpoutre\LaravelLogViewer\LogViewerController;
use App\Http\Controllers\TypeController;


Route::view('/', 'welcome');

Broadcast::routes();

Route::get('classes',               [TypeController::class, "all"])->name('types.all');
Route::get('classes/{type}/show',   [TypeController::class, "show"])->name('types.show');

Route::middleware(['auth'])->group(function () 
{
    Route::prefix('jobs')->group(function () {
        Route::queueMonitor();
    });
    
    Route::get('logs',      [LogViewerController::class,    'index']);
});

require __DIR__.'/channels.php';
