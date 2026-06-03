<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Livi@se') }} | San Martín</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="auth-shell font-sans text-gray-900 antialiased">
        <div class="liviase-shell min-h-screen flex flex-col sm:justify-center items-center px-5 pt-6 sm:pt-0">
            <div class="text-center sanmartin-auth-brand">
                <a href="/">
                    <img
                        src="{{ asset('images/institutional/san_martin_logo.png') }}"
                        alt="Fundación Universitaria San Martín"
                        class="sanmartin-auth-logo mx-auto"
                    >
                </a>
                <h1 class="liviase-brand-text mt-4 text-4xl leading-none">Livi@se</h1>
                <p class="mx-auto mt-2 max-w-sm text-sm text-gray-600">Acompañamiento académico y empresarial para microempresarios.</p>
            </div>

            <div class="liviase-card w-full sm:max-w-md mt-6 px-6 py-5 overflow-hidden">
                {{ $slot }}
            </div>
        </div>
    </body>
</html>
