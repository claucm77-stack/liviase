@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-5">
        <div class="mb-5">
            <h2 class="text-lg font-semibold">Nuevo contenido</h2>
            <p class="text-sm text-gray-600 mt-1">Selecciona el tipo y completa solo la información correspondiente.</p>
        </div>

        <form method="POST" action="{{ route('admin.contents.store') }}" class="space-y-5">
            @csrf
            @include('admin.contents._form', ['submitLabel' => 'Guardar contenido'])
        </form>
    </div>
@endsection
