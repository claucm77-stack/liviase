@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-lg font-semibold mb-4">Editar Micronegocio</h2>

        <form method="POST" action="{{ route('admin.microbusinesses.update', $business) }}" class="space-y-4">
            @method('PUT')
            @include('admin.microbusinesses._form')
        </form>
    </div>
@endsection
