<?php

use Illuminate\Support\Facades\Route;

use Rap2hpoutre\LaravelLogViewer\LogViewerController;


Route::view('/', 'welcome');

Broadcast::routes();

Route::middleware(['auth'])->group(function () 
{
    Route::prefix('jobs')->group(function () {
        Route::queueMonitor();
    });
    
    Route::get('logs',      [LogViewerController::class,    'index']);
});

require __DIR__.'/channels.php';
