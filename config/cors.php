<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | This configuration determines the Cross-Origin Resource Sharing
    | headers that will be returned when your application needs to be
    | accessed from different domains or origins.
    |
    */

    'paths' => explode(',', env(
        'CORS_ALLOWED_PATHS',
        'api/*,sanctum/*,/login,/register'
    )),

    'allowed_methods' => explode(',', env(
        'CORS_ALLOWED_METHODS',
        'GET,POST,PUT,PATCH,DELETE,OPTIONS'
    )),

    'allowed_origins' => explode(',', env(
        'CORS_ALLOWED_ORIGINS',
        'http://localhost:3000,http://localhost:4200,http://localhost:8080'
    )),

    'allowed_origins_patterns' => [],

    'allowed_headers' => explode(',', env(
        'CORS_ALLOWED_HEADERS',
        'Content-Type,Authorization,X-Requested-With,X-XSRF-Token,Accept,Origin'
    )),

    'exposed_headers' => explode(',', env(
        'CORS_EXPOSED_HEADERS',
        'Authorization'
    )),

    'max_age' => env('CORS_MAX_AGE', 3600),

    'supports_credentials' => env('CORS_SUPPORTS_CREDENTIALS', true),
];
