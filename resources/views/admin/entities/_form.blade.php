@php
    $inputClass = 'w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#4c8d93] focus:border-[#4c8d93]';
    $links = old('links', $entity->links ?? [['name' => '', 'url' => '']]);
    $documents = old('existing_documents', $entity->documents ?? []);
@endphp

@if ($errors->any())
    <div class="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-700">
        <p class="font-semibold">Revisa la información del formulario:</p>
        <ul class="mt-2 list-disc pl-5">
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<div class="grid gap-4 md:grid-cols-2">
    <div>
        <label class="block text-sm font-medium mb-1">Nombre de la entidad</label>
        <input type="text" name="name" value="{{ old('name', $entity->name ?? '') }}" class="{{ $inputClass }}" required>
    </div>

    <div>
        <label class="block text-sm font-medium mb-1">Foto o logo de la entidad</label>
        <input type="file" name="image" accept="image/*" class="{{ $inputClass }}">
        @isset($entity)
            @if ($entity->image_path)
                <p class="mt-1 text-xs text-gray-500">Hay una imagen cargada. Sube una nueva para reemplazarla.</p>
            @endif
        @endisset
    </div>
</div>

<div>
    <label class="block text-sm font-medium mb-1">Enlace principal (opcional)</label>
    <input type="url" name="main_url" value="{{ old('main_url', $entity->main_url ?? '') }}" class="{{ $inputClass }}" placeholder="https://...">
</div>

<label class="inline-flex items-center gap-2 text-sm font-semibold">
    <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $entity->is_active ?? true))>
    Entidad activa y visible
</label>

<section class="rounded-lg border border-gray-200 bg-gray-50 p-4 space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
            <h3 class="text-base font-semibold text-gray-900">Enlaces con nombre</h3>
            <p class="text-sm text-gray-600">Cada enlace aparecerá como botón dentro de la entidad.</p>
        </div>
        <button type="button" data-add-link class="rounded-md border px-3 py-2 text-sm font-semibold">+ Agregar enlace</button>
    </div>

    <div data-links-wrapper class="space-y-3">
        @foreach ($links as $index => $link)
            <div data-link-row class="grid gap-3 rounded-md border border-gray-200 bg-white p-3 md:grid-cols-[1fr_1fr_auto]">
                <div>
                    <label class="block text-xs font-semibold mb-1">Nombre</label>
                    <input type="text" name="links[{{ $index }}][name]" value="{{ $link['name'] ?? '' }}" class="{{ $inputClass }}" placeholder="Ej. Cámara de Comercio Bogotá">
                </div>
                <div>
                    <label class="block text-xs font-semibold mb-1">URL</label>
                    <input type="url" name="links[{{ $index }}][url]" value="{{ $link['url'] ?? '' }}" class="{{ $inputClass }}" placeholder="https://...">
                </div>
                <div class="flex items-end">
                    <button type="button" data-remove-row class="rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white">Eliminar</button>
                </div>
            </div>
        @endforeach
    </div>
</section>

<section class="rounded-lg border border-gray-200 bg-gray-50 p-4 space-y-4">
    <div>
        <h3 class="text-base font-semibold text-gray-900">Documentos PDF con nombre</h3>
        <p class="text-sm text-gray-600">Carga documentos PDF para que aparezcan como recursos descargables.</p>
    </div>

    @if (!empty($documents))
        <div class="space-y-3">
            <h4 class="text-sm font-semibold text-gray-800">PDF cargados</h4>
            @foreach ($documents as $index => $document)
                <div class="grid gap-3 rounded-md border border-gray-200 bg-white p-3 md:grid-cols-[1fr_auto]">
                    <div>
                        <label class="block text-xs font-semibold mb-1">Nombre del PDF</label>
                        <input type="text" name="existing_documents[{{ $index }}][name]" value="{{ $document['name'] ?? '' }}" class="{{ $inputClass }}">
                        <input type="hidden" name="existing_documents[{{ $index }}][path]" value="{{ $document['path'] ?? '' }}">
                        <input type="hidden" name="existing_documents[{{ $index }}][url]" value="{{ $document['url'] ?? '' }}">
                    </div>
                    <label class="flex items-end gap-2 text-sm font-semibold text-red-700">
                        <input type="checkbox" name="existing_documents[{{ $index }}][remove]" value="1">
                        Eliminar
                    </label>
                </div>
            @endforeach
        </div>
    @endif

    <div class="flex flex-wrap items-center justify-between gap-3">
        <h4 class="text-sm font-semibold text-gray-800">Nuevos PDF</h4>
        <button type="button" data-add-document class="rounded-md border px-3 py-2 text-sm font-semibold">+ Agregar PDF</button>
    </div>

    <div data-documents-wrapper class="space-y-3">
        <div data-document-row class="grid gap-3 rounded-md border border-gray-200 bg-white p-3 md:grid-cols-[1fr_1fr_auto]">
            <div>
                <label class="block text-xs font-semibold mb-1">Nombre del PDF</label>
                <input type="text" name="new_document_names[0]" class="{{ $inputClass }}" placeholder="Ej. Guía de formalización">
            </div>
            <div>
                <label class="block text-xs font-semibold mb-1">Archivo PDF</label>
                <input type="file" name="new_document_files[0]" accept="application/pdf" class="{{ $inputClass }}">
            </div>
            <div class="flex items-end">
                <button type="button" data-remove-row class="rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white">Eliminar</button>
            </div>
        </div>
    </div>
</section>

<div class="flex flex-wrap gap-2 pt-2">
    <button type="submit" class="bg-blue-700 hover:bg-blue-800 text-white px-4 py-2 rounded-md text-sm font-medium">
        {{ $submitLabel }}
    </button>
    <a href="{{ route('admin.entities.index') }}" class="px-4 py-2 rounded-md text-sm border">Cancelar</a>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const linksWrapper = document.querySelector('[data-links-wrapper]');
        const documentsWrapper = document.querySelector('[data-documents-wrapper]');
        let linkIndex = linksWrapper.querySelectorAll('[data-link-row]').length;
        let documentIndex = documentsWrapper.querySelectorAll('[data-document-row]').length;

        const bindRemove = (row) => {
            row.querySelector('[data-remove-row]')?.addEventListener('click', () => {
                row.remove();
            });
        };

        linksWrapper.querySelectorAll('[data-link-row]').forEach(bindRemove);
        documentsWrapper.querySelectorAll('[data-document-row]').forEach(bindRemove);

        document.querySelector('[data-add-link]')?.addEventListener('click', () => {
            const row = document.createElement('div');
            row.dataset.linkRow = '';
            row.className = 'grid gap-3 rounded-md border border-gray-200 bg-white p-3 md:grid-cols-[1fr_1fr_auto]';
            row.innerHTML = `
                <div>
                    <label class="block text-xs font-semibold mb-1">Nombre</label>
                    <input type="text" name="links[${linkIndex}][name]" class="{{ $inputClass }}" placeholder="Ej. Cámara de Comercio Bogotá">
                </div>
                <div>
                    <label class="block text-xs font-semibold mb-1">URL</label>
                    <input type="url" name="links[${linkIndex}][url]" class="{{ $inputClass }}" placeholder="https://...">
                </div>
                <div class="flex items-end">
                    <button type="button" data-remove-row class="rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white">Eliminar</button>
                </div>
            `;
            linksWrapper.appendChild(row);
            bindRemove(row);
            linkIndex += 1;
        });

        document.querySelector('[data-add-document]')?.addEventListener('click', () => {
            const row = document.createElement('div');
            row.dataset.documentRow = '';
            row.className = 'grid gap-3 rounded-md border border-gray-200 bg-white p-3 md:grid-cols-[1fr_1fr_auto]';
            row.innerHTML = `
                <div>
                    <label class="block text-xs font-semibold mb-1">Nombre del PDF</label>
                    <input type="text" name="new_document_names[${documentIndex}]" class="{{ $inputClass }}" placeholder="Ej. Guía de formalización">
                </div>
                <div>
                    <label class="block text-xs font-semibold mb-1">Archivo PDF</label>
                    <input type="file" name="new_document_files[${documentIndex}]" accept="application/pdf" class="{{ $inputClass }}">
                </div>
                <div class="flex items-end">
                    <button type="button" data-remove-row class="rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white">Eliminar</button>
                </div>
            `;
            documentsWrapper.appendChild(row);
            bindRemove(row);
            documentIndex += 1;
        });
    });
</script>
