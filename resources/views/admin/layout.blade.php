<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livi@se | Panel San Martín</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="admin-shell liviase-shell text-gray-900 min-h-screen">
    <header class="liviase-nav sanmartin-admin-header">
        <img
            src="{{ asset('images/institutional/san_martin_header_corner.png') }}"
            alt=""
            class="sanmartin-header-corner"
            aria-hidden="true"
        >
        <div class="sanmartin-header-inner max-w-6xl mx-auto px-4 py-4">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                <div class="sanmartin-header-brand">
                    <img
                        src="{{ asset('images/institutional/san_martin_logo_white.png') }}"
                        alt="Fundación Universitaria San Martín"
                        class="sanmartin-nav-logo"
                    >
                    <h1 class="text-2xl font-black leading-tight">Administrador de Plataforma</h1>
                </div>
                <div>
                    <div class="flex flex-col gap-3 lg:items-end">
                        <nav class="sanmartin-admin-nav flex flex-wrap items-center justify-start gap-2 text-sm lg:justify-end">
                            @if (auth()->user()?->isAdmin())
                                <a href="{{ route('admin.users.index') }}">Usuarios</a>
                                <a href="{{ route('admin.microbusiness-fields.index') }}">Campos</a>
                                <a href="{{ route('admin.microbusinesses.index') }}">Micronegocios</a>
                                <a href="{{ route('admin.contents.index') }}">Contenidos</a>
                                <a href="{{ route('admin.logs.index') }}">Logs</a>
                                <a href="{{ route('admin.settings.edit') }}">Configuración</a>
                            @endif
                            <a href="{{ route('dashboard') }}">Dashboard</a>
                        </nav>

                        @auth
                            <form method="POST" action="{{ route('logout') }}" class="m-0 flex items-center gap-3">
                                @csrf
                                <span class="hidden text-xs font-semibold text-white/80 sm:inline">
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
    <footer class="sanmartin-admin-footer">
        <img
            src="{{ asset('images/institutional/san_martin_footer.png') }}"
            alt="Firma institucional Fundación Universitaria San Martín"
            class="sanmartin-footer-signature"
        >
    </footer>
</body>
</html>
