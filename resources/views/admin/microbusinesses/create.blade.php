@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-lg font-semibold mb-4">Nuevo Micronegocio</h2>

        <form method="POST" action="{{ route('admin.microbusinesses.store') }}" class="space-y-4">
            @include('admin.microbusinesses._form')
        </form>
    </div>
@endsection
