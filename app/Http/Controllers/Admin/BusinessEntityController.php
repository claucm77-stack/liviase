<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\BusinessEntity;
use App\Services\FirestoreSyncService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class BusinessEntityController extends Controller
{
    public function __construct(private readonly FirestoreSyncService $firestore)
    {
    }

    public function index(): View
    {
        $entities = BusinessEntity::query()
            ->latest()
            ->paginate(15);

        return view('admin.entities.index', compact('entities'));
    }

    public function create(): View
    {
        return view('admin.entities.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $this->validateEntity($request);

        $entity = BusinessEntity::create([
            'name' => $validated['name'],
            'image_path' => $this->storeImage($request),
            'main_url' => $validated['main_url'] ?? null,
            'links' => $this->normalizedLinks($request),
            'documents' => $this->storeNewDocuments($request),
            'is_active' => $request->boolean('is_active', true),
        ]);

        $this->firestore->syncBusinessEntity($entity);
        $this->audit('entity_created', "Entidad creada: {$entity->name}", $entity);

        return redirect()
            ->route('admin.entities.index')
            ->with('status', 'Entidad creada correctamente.');
    }

    public function edit(BusinessEntity $entity): View
    {
        return view('admin.entities.edit', compact('entity'));
    }

    public function update(Request $request, BusinessEntity $entity): RedirectResponse
    {
        $validated = $this->validateEntity($request);

        $imagePath = $entity->image_path;
        if ($request->hasFile('image')) {
            $this->deleteFile($imagePath);
            $imagePath = $this->storeImage($request);
        }

        $entity->update([
            'name' => $validated['name'],
            'image_path' => $imagePath,
            'main_url' => $validated['main_url'] ?? null,
            'links' => $this->normalizedLinks($request),
            'documents' => $this->normalizedExistingDocuments($request, $entity)
                ->merge($this->storeNewDocuments($request))
                ->values()
                ->all(),
            'is_active' => $request->boolean('is_active'),
        ]);

        $this->firestore->syncBusinessEntity($entity);
        $this->audit('entity_updated', "Entidad actualizada: {$entity->name}", $entity);

        return redirect()
            ->route('admin.entities.index')
            ->with('status', 'Entidad actualizada correctamente.');
    }

    public function destroy(BusinessEntity $entity): RedirectResponse
    {
        $name = $entity->name;
        $this->firestore->deleteBusinessEntity($entity);
        $this->deleteFile($entity->image_path);

        collect($entity->documents ?? [])
            ->pluck('path')
            ->filter()
            ->each(fn (string $path) => $this->deleteFile($path));

        $entity->delete();
        $this->audit('entity_deleted', "Entidad eliminada: {$name}");

        return redirect()
            ->route('admin.entities.index')
            ->with('status', 'Entidad eliminada correctamente.');
    }

    private function validateEntity(Request $request): array
    {
        return $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'main_url' => ['nullable', 'url', 'max:500'],
            'image' => ['nullable', 'image', 'max:4096'],
            'is_active' => ['nullable', 'boolean'],
            'links' => ['nullable', 'array'],
            'links.*.name' => ['nullable', 'required_with:links.*.url', 'string', 'max:180'],
            'links.*.url' => ['nullable', 'required_with:links.*.name', 'url', 'max:500'],
            'existing_documents' => ['nullable', 'array'],
            'existing_documents.*.name' => ['nullable', 'string', 'max:180'],
            'existing_documents.*.path' => ['nullable', 'string', 'max:500'],
            'existing_documents.*.url' => ['nullable', 'url', 'max:500'],
            'existing_documents.*.remove' => ['nullable', 'boolean'],
            'new_document_names' => ['nullable', 'array'],
            'new_document_names.*' => ['nullable', 'required_with:new_document_files.*', 'string', 'max:180'],
            'new_document_files' => ['nullable', 'array'],
            'new_document_files.*' => ['nullable', 'file', 'mimes:pdf', 'max:10240'],
        ]);
    }

    private function normalizedLinks(Request $request): array
    {
        return collect($request->input('links', []))
            ->filter(fn ($item) => filled($item['name'] ?? null) && filled($item['url'] ?? null))
            ->map(fn ($item) => [
                'name' => trim((string) $item['name']),
                'url' => trim((string) $item['url']),
            ])
            ->values()
            ->all();
    }

    private function normalizedExistingDocuments(Request $request, BusinessEntity $entity): \Illuminate\Support\Collection
    {
        $current = collect($entity->documents ?? [])->keyBy('path');
        $submitted = collect($request->input('existing_documents', []));

        return $submitted
            ->filter(fn ($item) => filled($item['path'] ?? null))
            ->reject(function ($item) {
                if (filter_var($item['remove'] ?? false, FILTER_VALIDATE_BOOLEAN)) {
                    $this->deleteFile((string) ($item['path'] ?? ''));
                    return true;
                }

                return false;
            })
            ->map(function ($item) use ($current) {
                $path = (string) $item['path'];
                $stored = $current->get($path, []);

                return [
                    'name' => trim((string) ($item['name'] ?? $stored['name'] ?? 'Documento PDF')),
                    'path' => $path,
                    'url' => (string) ($item['url'] ?? $stored['url'] ?? Storage::disk('public')->url($path)),
                ];
            })
            ->filter(fn ($item) => filled($item['name']) && filled($item['path']));
    }

    private function storeNewDocuments(Request $request): array
    {
        $names = $request->input('new_document_names', []);

        return collect($request->file('new_document_files', []))
            ->map(function ($file, int $index) use ($names) {
                if (!$file) {
                    return null;
                }

                $path = $file->store('entities/documents', 'public');

                return [
                    'name' => trim((string) ($names[$index] ?? 'Documento PDF')),
                    'path' => $path,
                    'url' => Storage::disk('public')->url($path),
                ];
            })
            ->filter(fn ($item) => $item !== null && filled($item['name']))
            ->values()
            ->all();
    }

    private function storeImage(Request $request): ?string
    {
        return $request->hasFile('image')
            ? $request->file('image')->store('entities/images', 'public')
            : null;
    }

    private function deleteFile(?string $path): void
    {
        if ($path) {
            Storage::disk('public')->delete($path);
        }
    }

    private function audit(string $action, string $description, ?BusinessEntity $entity = null): void
    {
        AuditLog::log(
            auth()->id(),
            $action,
            $description,
            'entities',
            request()->ip(),
            request()->userAgent(),
            $entity ? ['entity_id' => $entity->id] : null,
        );
    }
}
