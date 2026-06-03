<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livi@se | Panel San Martín</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="admin-shell liviase-shell text-gray-900 min-h-screen">
    <header class="liviase-nav">
        <div class="sanmartin-header-inner max-w-6xl mx-auto px-4 py-4 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="sanmartin-header-brand flex items-center gap-4">
                <img
                    src="{{ asset('images/institutional/san_martin_shield.png') }}"
                    alt="Escudo Fundación Universitaria San Martín"
                    class="sanmartin-nav-shield"
                >
                <div>
                    <span class="sanmartin-monogram" aria-label="Fundación Universitaria San Martín">NM</span>
                    <h1 class="text-xl font-black">Administrador de Plataforma</h1>
                </div>
            </div>
            <div class="flex flex-col gap-3 sm:items-end">
                <nav class="flex flex-wrap items-center justify-start gap-2 text-sm sm:justify-end">
                    @if (auth()->user()?->isAdmin())
                        <a href="{{ route('admin.users.index') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Usuarios</a>
                        <a href="{{ route('admin.microbusiness-fields.index') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Campos</a>
                        <a href="{{ route('admin.microbusinesses.index') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Micronegocios</a>
                        <a href="{{ route('admin.contents.index') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Contenidos</a>
                        <a href="{{ route('admin.logs.index') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Logs</a>
                        <a href="{{ route('admin.settings.edit') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Configuración</a>
                    @endif
                    <a href="{{ route('dashboard') }}" class="rounded-md px-3 py-2 hover:bg-white/15">Dashboard</a>
                </nav>

                @auth
                    <form method="POST" action="{{ route('logout') }}" class="m-0 flex items-center gap-3">
                        @csrf
                        <span class="hidden text-xs font-semibold text-white/75 sm:inline">
                            {{ auth()->user()->name ?: auth()->user()->email }}
                        </span>
                        <button
                            type="submit"
                            class="rounded-md border border-white/40 bg-white/15 px-3 py-2 text-sm font-bold text-white shadow-sm hover:bg-white/25"
                        >
                            Cerrar sesión
                        </button>
                    </form>
                @endauth
            </div>
        </div>
    </header>

    <main class="max-w-6xl mx-auto px-4 py-6">
        @if (session('status'))
            <div class="mb-4 rounded-md bg-green-100 border border-green-300 text-green-800 px-4 py-3">
                {{ session('status') }}
            </div>
        @endif

        @if ($errors->any())
            <div class="mb-4 rounded-md bg-red-100 border border-red-300 text-red-800 px-4 py-3">
                <p class="font-medium mb-2">Hay errores en el formulario:</p>
                <ul class="list-disc pl-5 text-sm">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @yield('content')
    </main>
</body>
</html>
