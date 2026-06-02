@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between mb-4">
            <h2 class="text-lg font-semibold">Logs y actividad</h2>
            <span class="text-sm text-gray-500">{{ $logs->total() }} eventos registrados</span>
        </div>

        <form method="GET" class="grid gap-3 md:grid-cols-4 mb-4">
            <input type="search" name="search" value="{{ request('search') }}" placeholder="Buscar accion o detalle" class="border rounded-md px-3 py-2">
            <select name="module" class="border rounded-md px-3 py-2">
                <option value="">Todos los modulos</option>
                @foreach ($modules as $module)
                    <option value="{{ $module }}" @selected(request('module') === $module)>{{ $module }}</option>
                @endforeach
            </select>
            <select name="user_id" class="border rounded-md px-3 py-2">
                <option value="">Todos los usuarios</option>
                @foreach ($users as $user)
                    <option value="{{ $user->id }}" @selected((string) request('user_id') === (string) $user->id)>{{ $user->name ?: $user->email }}</option>
                @endforeach
            </select>
            <button class="rounded-md px-3 py-2 font-semibold text-white" style="background-color:#193760;">Filtrar</button>
        </form>

        <div class="overflow-x-auto">
            <table class="w-full text-sm border border-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="text-left px-3 py-2 border-b">Fecha</th>
                        <th class="text-left px-3 py-2 border-b">Usuario</th>
                        <th class="text-left px-3 py-2 border-b">Modulo</th>
                        <th class="text-left px-3 py-2 border-b">Accion</th>
                        <th class="text-left px-3 py-2 border-b">Detalle</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($logs as $log)
                        <tr class="border-b align-top">
                            <td class="px-3 py-2 whitespace-nowrap">{{ $log->created_at?->format('Y-m-d H:i') }}</td>
                            <td class="px-3 py-2">{{ $log->user?->name ?? $log->user?->email ?? '-' }}</td>
                            <td class="px-3 py-2">{{ $log->module }}</td>
                            <td class="px-3 py-2 font-semibold">{{ $log->action }}</td>
                            <td class="px-3 py-2">
                                <p>{{ $log->description }}</p>
                                @if ($log->metadata)
                                    <pre class="mt-2 rounded bg-gray-100 p-2 text-xs overflow-auto">{{ json_encode($log->metadata, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) }}</pre>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-3 py-4 text-center text-gray-500">No hay logs registrados.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $logs->links() }}
        </div>
    </div>
@endsection
