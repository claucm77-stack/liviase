<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Stateful Domains
    |--------------------------------------------------------------------------
    |
    | This option determines which domains will receive API tokens in a stateful
    | manner when making requests to your application. These domains will
    | receive authentication cookies/sanctum tokens.
    |
    | For development, you may want to add your local domain.
    |
    */

    'stateful' => explode(',', env(
        'SANCTUM_STATEFUL_DOMAINS',
        sprintf(
            '%s%s',
            'localhost,localhost:3000,localhost:8080,127.0.0.1,127.0.0.1:8000,::1',
            env('APP_URL') ? ',' . parse_url(env('APP_URL'), PHP_URL_HOST) : ''
        )
    )),

    /*
    |--------------------------------------------------------------------------
    | Expiration Minutes
    |--------------------------------------------------------------------------
    |
    | Here you may specify the number of minutes that authentication tokens
    | will be considered valid. This setting will control when tokens expire.
    | Default is 24 hours (1440 minutes).
    |
    */

    'expiration' => env('SANCTUM_EXPIRATION', 1440),

    /*
    |--------------------------------------------------------------------------
    | Token Prefix
    |--------------------------------------------------------------------------
    |
    | This option configures the prefix for API tokens to avoid any conflicts
    | with other authentication mechanisms in your application.
    |
    */

    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

    /*
    |--------------------------------------------------------------------------
    | Middleware
    |--------------------------------------------------------------------------
    |
    | This option configures the middleware that protects API routes. By
    | default, sanctum uses stateful cookies for API authentication.
    |
    */

    'middleware' => env(
        'SANCTUM_MIDDLEWARE',
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class
    ),

    /*
    |--------------------------------------------------------------------------
    | Token Expiration Hours
    |--------------------------------------------------------------------------
    |
    | This is a custom setting to set token expiration in hours.
    | Note: This overrides the 'expiration' setting if set.
    |
    */

    'token_expiration_hours' => env('SANCTUM_TOKEN_EXPIRATION_HOURS', 24),

    /*
    |--------------------------------------------------------------------------
    | Ability Prefix
    |--------------------------------------------------------------------------
    |
    | This option configures a prefix for abilities to help avoid conflicts
    | with other authentication mechanisms.
    |
    */

    'ability_prefix' => env('SANCTUM_ABILITY_PREFIX', 'sanctum:'),

    /*
    |--------------------------------------------------------------------------
    | Rate Limiting
    |--------------------------------------------------------------------------
    |
    | Configuration for API rate limiting per user.
    |
    */

    'rate_limit' => env('SANCTUM_RATE_LIMIT', 60),

    /*
    |--------------------------------------------------------------------------
    | Token Renewal
    |--------------------------------------------------------------------------
    |
    | Enable token renewal functionality for expired tokens.
    |
    */

    'token_renewal' => env('SANCTUM_TOKEN_RENEWAL', true),
];
