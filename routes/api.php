<?php

use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Auth\PasswordController;
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\Auth\SessionController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\MicrobusinessFieldController;
use App\Http\Controllers\Api\UserController;
use App\Constants\Roles;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes (No Authentication Required)
|--------------------------------------------------------------------------
*/
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [RegisterController::class, 'register']);
Route::post('/auth/forgot', [PasswordController::class, 'forgot']);
Route::post('/auth/reset', [PasswordController::class, 'reset']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Authentication Required)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);
    
    // Session management
    Route::get('/auth/sessions', [SessionController::class, 'index']);
    Route::delete('/auth/sessions/{tokenId}', [SessionController::class, 'destroy']);
    Route::post('/auth/sessions/revoke-all', [SessionController::class, 'revokeAll']);
    
    // Password management
    Route::post('/auth/password/change', [PasswordController::class, 'change']);
});

/*
|--------------------------------------------------------------------------
| Admin Routes (Admin Role Required)
|--------------------------------------------------------------------------
*/
Route::middleware(['auth:sanctum', 'role:' . Roles::ADMIN_TI . ',' . Roles::LEGACY_ADMIN])->group(function () {
    // User management
    Route::apiResource('users', UserController::class)->except(['create', 'edit']);
});

/*
|--------------------------------------------------------------------------
| Public API Routes (Public Access)
|--------------------------------------------------------------------------
*/
Route::get('/contents', [ContentController::class, 'index'])->name('api.contents.index');
Route::get('/microbusiness-fields', [MicrobusinessFieldController::class, 'index'])->name('api.microbusiness-fields.index');
