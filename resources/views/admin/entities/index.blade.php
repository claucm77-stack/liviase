@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold">Entidades</h2>
            <a
                href="{{ route('admin.entities.create') }}"
                class="inline-flex items-center justify-center px-3 py-2 rounded-md text-sm font-semibold shadow-md border"
                style="min-height:40px;background-color:#4c8d93;color:#ffffff !important;border-color:#3c747a;text-decoration:none;"
            >
                + Nueva entidad
            </a>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-sm border border-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left px-3 py-2 border-b">Nombre</th>
                        <th class="text-left px-3 py-2 border-b">Enlace principal</th>
                        <th class="text-left px-3 py-2 border-b">Recursos</th>
                        <th class="text-left px-3 py-2 border-b">Estado</th>
                        <th class="text-left px-3 py-2 border-b">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($entities as $entity)
                        <tr class="border-b">
                            <td class="px-3 py-2 font-semibold">{{ $entity->name }}</td>
                            <td class="px-3 py-2">
                                @if ($entity->main_url)
                                    <a href="{{ $entity->main_url }}" target="_blank" rel="noopener noreferrer" class="text-blue-700 hover:underline">
                                        Abrir
                                    </a>
                                @else
                                    -
                                @endif
                            </td>
                            <td class="px-3 py-2">
                                {{ count($entity->links ?? []) }} enlaces /
                                {{ count($entity->documents ?? []) }} PDF
                            </td>
                            <td class="px-3 py-2">
                                <span class="{{ $entity->is_active ? 'text-green-700' : 'text-gray-500' }} font-semibold">
                                    {{ $entity->is_active ? 'Activa' : 'Inactiva' }}
                                </span>
                            </td>
                            <td class="px-3 py-2">
                                <div class="flex gap-2">
                                    <a href="{{ route('admin.entities.edit', $entity) }}" class="text-blue-700 hover:underline">Editar</a>
                                    <form method="POST" action="{{ route('admin.entities.destroy', $entity) }}" onsubmit="return confirm('¿Eliminar entidad?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs font-medium shadow-sm transition-colors">Eliminar</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-3 py-4 text-center text-gray-500">No hay entidades registradas.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $entities->links() }}
        </div>
    </div>
@endsection
