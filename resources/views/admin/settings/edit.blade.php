@extends('admin.layout')

@section('content')
    <div class="bg-white rounded-lg shadow p-4 max-w-3xl">
        <h2 class="text-lg font-semibold mb-4">Configuración de plataforma</h2>

        <form method="POST" action="{{ route('admin.settings.update') }}" class="space-y-4">
            @csrf
            @method('PATCH')

            <div>
                <label class="block text-sm font-medium mb-1">Nombre de la plataforma</label>
                <input
                    type="text"
                    name="platform_name"
                    value="{{ old('platform_name', $settings->platform_name) }}"
                    class="border rounded-md px-3 py-2 w-full"
                    required
                >
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Email de contacto</label>
                <input
                    type="email"
                    name="contact_email"
                    value="{{ old('contact_email', $settings->contact_email) }}"
                    class="border rounded-md px-3 py-2 w-full"
                >
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">WhatsApp de soporte</label>
                <input
                    type="text"
                    name="support_whatsapp"
                    value="{{ old('support_whatsapp', $settings->support_whatsapp) }}"
                    class="border rounded-md px-3 py-2 w-full"
                >
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Descripción</label>
                <textarea
                    name="about"
                    rows="4"
                    class="border rounded-md px-3 py-2 w-full"
                >{{ old('about', $settings->about) }}</textarea>
            </div>

            <div class="flex items-center gap-2">
                <input
                    type="checkbox"
                    name="maintenance_mode"
                    value="1"
                    {{ old('maintenance_mode', $settings->maintenance_mode) ? 'checked' : '' }}
                >
                <label class="text-sm">Activar modo mantenimiento</label>
            </div>

            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md">
                Guardar configuración
            </button>
        </form>
    </div>
@endsection
