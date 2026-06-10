@extends('admin.layout')

@section('content')
    <div class="max-w-4xl bg-white rounded-lg shadow p-5">
        <h2 class="text-lg font-semibold mb-4">Editar entidad</h2>

        <form method="POST" action="{{ route('admin.entities.update', $entity) }}" enctype="multipart/form-data" class="space-y-5">
            @csrf
            @method('PUT')

            @include('admin.entities._form', ['submitLabel' => 'Actualizar entidad'])
        </form>
    </div>
@endsection
