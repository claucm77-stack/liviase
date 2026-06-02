@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4">
            <h2 class="text-lg font-semibold">Micronegocios</h2>
            <a
                href="{{ route('admin.microbusinesses.create') }}"
                class="inline-flex items-center justify-center px-3 py-2 rounded-md text-sm font-semibold shadow-md border"
                style="min-height:40px;background-color:#4c8d93;color:#ffffff !important;border-color:#3c747a;text-decoration:none;"
            >
                + Nuevo micronegocio
            </a>
        </div>

        <form method="GET" class="grid gap-3 md:grid-cols-4 mb-4">
            <input type="search" name="search" value="{{ request('search') }}" placeholder="Buscar nombre, categoria o direccion" class="border rounded-md px-3 py-2">
            <select name="category" class="border rounded-md px-3 py-2">
                <option value="">Todas las categorias</option>
                @foreach ($categories as $category)
                    <option value="{{ $category }}" @selected(request('category') === $category)>{{ $category }}</option>
                @endforeach
            </select>
            <select name="status" class="border rounded-md px-3 py-2">
                <option value="">Todos los estados</option>
                <option value="activo" @selected(request('status') === 'activo')>Activo</option>
                <option value="inactivo" @selected(request('status') === 'inactivo')>Inactivo</option>
            </select>
            <button class="rounded-md px-3 py-2 font-semibold text-white" style="background-color:#193760;">Filtrar</button>
        </form>

        <div class="overflow-x-auto">
            <table class="w-full text-sm border border-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left px-3 py-2 border-b">Nombre</th>
                        <th class="text-left px-3 py-2 border-b">Categoria</th>
                        <th class="text-left px-3 py-2 border-b">Direccion</th>
                        <th class="text-left px-3 py-2 border-b">Estado</th>
                        <th class="text-left px-3 py-2 border-b">Rating</th>
                        <th class="text-left px-3 py-2 border-b">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($businesses as $business)
                        <tr class="border-b">
                            <td class="px-3 py-2 font-semibold">{{ $business->name }}</td>
                            <td class="px-3 py-2">{{ $business->category ?: '-' }}</td>
                            <td class="px-3 py-2">{{ $business->address ?: '-' }}</td>
                            <td class="px-3 py-2">
                                <span class="rounded-full px-2 py-1 text-xs font-bold {{ $business->isActive() ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }}">
                                    {{ ucfirst($business->status) }}
                                </span>
                            </td>
                            <td class="px-3 py-2">
                                {{ $business->average_rating ? number_format($business->average_rating, 1) : '-' }}
                                <span class="text-gray-500">({{ $business->ratings_count }})</span>
                            </td>
                            <td class="px-3 py-2">
                                <div class="flex gap-2">
                                    <a href="{{ route('admin.microbusinesses.edit', $business) }}" class="text-blue-700 hover:underline">Editar</a>
                                    <form method="POST" action="{{ route('admin.microbusinesses.destroy', $business) }}" onsubmit="return confirm('¿Eliminar micronegocio?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs font-medium shadow-sm transition-colors">Eliminar</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-3 py-4 text-center text-gray-500">No hay micronegocios registrados.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $businesses->links() }}
        </div>
    </div>
@endsection
