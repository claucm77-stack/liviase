@csrf

<div class="grid gap-4 md:grid-cols-2">
    <div>
        <label class="block text-sm font-medium mb-1">Nombre</label>
        <input type="text" name="name" value="{{ old('name', $business->name) }}" class="w-full border rounded-md px-3 py-2" required>
    </div>

    <div>
        <label class="block text-sm font-medium mb-1">Categoria</label>
        <input type="text" name="category" value="{{ old('category', $business->category) }}" class="w-full border rounded-md px-3 py-2">
    </div>
</div>

<div>
    <label class="block text-sm font-medium mb-1">Descripcion</label>
    <textarea name="description" rows="3" class="w-full border rounded-md px-3 py-2">{{ old('description', $business->description) }}</textarea>
</div>

<div>
    <label class="block text-sm font-medium mb-1">Direccion</label>
    <input type="text" name="address" value="{{ old('address', $business->address) }}" class="w-full border rounded-md px-3 py-2">
</div>

<div class="grid gap-4 md:grid-cols-2">
    <div>
        <label class="block text-sm font-medium mb-1">Latitud</label>
        <input type="number" step="0.0000001" name="latitude" value="{{ old('latitude', $business->latitude) }}" class="w-full border rounded-md px-3 py-2" required>
    </div>
    <div>
        <label class="block text-sm font-medium mb-1">Longitud</label>
        <input type="number" step="0.0000001" name="longitude" value="{{ old('longitude', $business->longitude) }}" class="w-full border rounded-md px-3 py-2" required>
    </div>
</div>

<div>
    <label class="block text-sm font-medium mb-1">URL de Google Maps</label>
    <input type="url" name="maps_url" value="{{ old('maps_url', $business->maps_url) }}" class="w-full border rounded-md px-3 py-2">
</div>

<div>
    <label class="block text-sm font-medium mb-1">URL de imagen</label>
    <input type="url" name="image_url" value="{{ old('image_url', $business->image_url) }}" class="w-full border rounded-md px-3 py-2">
</div>

<div class="grid gap-4 md:grid-cols-2">
    <div>
        <label class="block text-sm font-medium mb-1">Propietario ID</label>
        <input type="text" name="owner_id" value="{{ old('owner_id', $business->owner_id) }}" class="w-full border rounded-md px-3 py-2">
    </div>
    <div>
        <label class="block text-sm font-medium mb-1">Contacto</label>
        <input type="text" name="contact" value="{{ old('contact', $business->contact) }}" class="w-full border rounded-md px-3 py-2">
    </div>
</div>

<div class="grid gap-4 md:grid-cols-2">
    <div>
        <label class="block text-sm font-medium mb-1">Horario</label>
        <input type="text" name="schedule" value="{{ old('schedule', $business->schedule) }}" class="w-full border rounded-md px-3 py-2">
    </div>
    <div>
        <label class="block text-sm font-medium mb-1">Estado</label>
        <select name="status" class="w-full border rounded-md px-3 py-2" required>
            <option value="activo" @selected(old('status', $business->status) === 'activo')>Activo</option>
            <option value="inactivo" @selected(old('status', $business->status) === 'inactivo')>Inactivo</option>
        </select>
    </div>
</div>

<div class="grid gap-4 md:grid-cols-3">
    <div>
        <label class="block text-sm font-medium mb-1">Fecha de creacion en app</label>
        <input
            type="datetime-local"
            name="created_on_app_at"
            value="{{ old('created_on_app_at', $business->created_on_app_at ? $business->created_on_app_at->format('Y-m-d\TH:i') : now()->format('Y-m-d\TH:i')) }}"
            class="w-full border rounded-md px-3 py-2"
        >
    </div>
    <div>
        <label class="block text-sm font-medium mb-1">Rating promedio</label>
        <input type="number" min="0" max="5" step="0.01" name="average_rating" value="{{ old('average_rating', $business->average_rating) }}" class="w-full border rounded-md px-3 py-2">
    </div>
    <div>
        <label class="block text-sm font-medium mb-1">Total calificaciones</label>
        <input type="number" min="0" name="ratings_count" value="{{ old('ratings_count', $business->ratings_count ?? 0) }}" class="w-full border rounded-md px-3 py-2">
    </div>
</div>

<div class="flex gap-2">
    <button type="submit" class="bg-blue-700 hover:bg-blue-800 text-white px-4 py-2 rounded-md text-sm font-medium">Guardar</button>
    <a href="{{ route('admin.microbusinesses.index') }}" class="px-4 py-2 rounded-md text-sm border">Cancelar</a>
</div>
