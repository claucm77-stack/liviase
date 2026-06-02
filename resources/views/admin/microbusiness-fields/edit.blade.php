@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-lg font-semibold mb-4">Editar Campo de Micronegocio</h2>

        <form method="POST" action="{{ route('admin.microbusiness-fields.update', $microbusinessField) }}" class="space-y-4">
            @csrf
            @method('PUT')

            <div>
                <label class="block text-sm font-medium mb-1">Nombre</label>
                <input type="text" name="name" value="{{ old('name', $microbusinessField->name) }}" class="w-full border rounded-md px-3 py-2" required>
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Tipo</label>
                <select name="field_type" class="w-full border rounded-md px-3 py-2" required>
                    @foreach (['text','textarea','number','select','checkbox','date','email','url'] as $type)
                        <option value="{{ $type }}" @selected(old('field_type', $microbusinessField->field_type) === $type)>{{ $type }}</option>
                    @endforeach
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Opciones (separadas por coma)</label>
                <input
                    type="text"
                    name="options_text"
                    value="{{ old('options_text', is_array($microbusinessField->options_json) ? implode(',', $microbusinessField->options_json) : '') }}"
                    class="w-full border rounded-md px-3 py-2"
                >
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Orden</label>
                <input type="number" min="0" name="sort_order" value="{{ old('sort_order', $microbusinessField->sort_order) }}" class="w-full border rounded-md px-3 py-2">
            </div>

            <div class="flex gap-6">
                <label class="inline-flex items-center gap-2">
                    <input type="checkbox" name="is_required" value="1" @checked(old('is_required', $microbusinessField->is_required))>
                    <span class="text-sm">Requerido</span>
                </label>

                <label class="inline-flex items-center gap-2">
                    <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $microbusinessField->is_active))>
                    <span class="text-sm">Activo</span>
                </label>
            </div>

            <div class="flex gap-2">
                <button type="submit" class="bg-blue-700 hover:bg-blue-800 text-white px-4 py-2 rounded-md text-sm font-medium">Actualizar</button>
                <a href="{{ route('admin.microbusiness-fields.index') }}" class="px-4 py-2 rounded-md text-sm border">Cancelar</a>
            </div>
        </form>
    </div>
@endsection
