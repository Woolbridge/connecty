<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DiscoveryController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\TransactionController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    // Discovery endpoints
    Route::get('/nearby-users', [DiscoveryController::class, 'getNearbyUsers']);
    Route::post('/update-location', [DiscoveryController::class, 'updateLocation']);

    // Messaging endpoints
    Route::get('/messages/{userId}', [MessageController::class, 'getMessages']);
    Route::post('/messages', [MessageController::class, 'sendMessage']);
    Route::put('/messages/{message}/read', [MessageController::class, 'markAsRead']);
    Route::post('/typing', [MessageController::class, 'typing']);

    // In-App Purchase endpoints
    Route::post('/purchase', [TransactionController::class, 'makePurchase']);
});
