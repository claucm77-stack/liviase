@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold">Campos de Micronegocios</h2>
            <a
                href="{{ route('admin.microbusiness-fields.create') }}"
                class="inline-flex items-center justify-center px-3 py-2 rounded-md text-sm font-semibold shadow-md border"
                style="min-height:40px;background-color:#4c8d93;color:#ffffff !important;border-color:#3c747a;text-decoration:none;"
            >
                + Nuevo campo
            </a>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-sm border border-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left px-3 py-2 border-b">Nombre</th>
                        <th class="text-left px-3 py-2 border-b">Tipo</th>
                        <th class="text-left px-3 py-2 border-b">Requerido</th>
                        <th class="text-left px-3 py-2 border-b">Orden</th>
                        <th class="text-left px-3 py-2 border-b">Estado</th>
                        <th class="text-left px-3 py-2 border-b">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($fields as $field)
                        <tr class="border-b">
                            <td class="px-3 py-2">{{ $field->name }}</td>
                            <td class="px-3 py-2">{{ $field->field_type }}</td>
                            <td class="px-3 py-2">{{ $field->is_required ? 'Sí' : 'No' }}</td>
                            <td class="px-3 py-2">{{ $field->sort_order }}</td>
                            <td class="px-3 py-2">
                                @if ($field->is_active)
                                    <span class="text-green-700 font-medium">Activo</span>
                                @else
                                    <span class="text-red-700 font-medium">Inactivo</span>
                                @endif
                            </td>
                            <td class="px-3 py-2">
                                <div class="flex gap-2">
                                    <a href="{{ route('admin.microbusiness-fields.edit', $field) }}" class="text-blue-700 hover:underline">Editar</a>
                                    <form method="POST" action="{{ route('admin.microbusiness-fields.destroy', $field) }}" onsubmit="return confirm('¿Eliminar campo?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs font-medium shadow-sm transition-colors">Eliminar</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-3 py-4 text-center text-gray-500">No hay campos registrados.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $fields->links() }}
        </div>
    </div>
@endsection
