@extends('admin.layout')

@section('content')
    <div class="max-w-4xl bg-white rounded-lg shadow p-5">
        <h2 class="text-lg font-semibold mb-4">Crear entidad</h2>

        <form method="POST" action="{{ route('admin.entities.store') }}" enctype="multipart/form-data" class="space-y-5">
            @csrf

            @include('admin.entities._form', ['submitLabel' => 'Guardar entidad'])
        </form>
    </div>
@endsection
