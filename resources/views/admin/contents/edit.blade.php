@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-5">
        <div class="mb-5">
            <h2 class="text-lg font-semibold">Editar contenido</h2>
            <p class="text-sm text-gray-600 mt-1">El formulario se adapta al tipo de contenido seleccionado.</p>
        </div>

        <form method="POST" action="{{ route('admin.contents.update', $content) }}" class="space-y-5">
            @csrf
            @method('PUT')
            @include('admin.contents._form', ['submitLabel' => 'Actualizar contenido'])
        </form>
    </div>
@endsection
