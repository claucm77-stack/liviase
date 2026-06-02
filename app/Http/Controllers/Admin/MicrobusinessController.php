<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Microbusiness;
use App\Services\FirestoreSyncService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class MicrobusinessController extends Controller
{
    public function __construct(private readonly FirestoreSyncService $firestore)
    {
    }

    public function index(Request $request): View
    {
        $query = Microbusiness::query()->latest();

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        if ($request->filled('search')) {
            $search = trim((string) $request->query('search'));
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('category', 'like', "%{$search}%")
                    ->orWhere('address', 'like', "%{$search}%");
            });
        }

        $businesses = $query->paginate(15)->withQueryString();
        $categories = Microbusiness::query()
            ->whereNotNull('category')
            ->where('category', '<>', '')
            ->distinct()
            ->orderBy('category')
            ->pluck('category');

        return view('admin.microbusinesses.index', compact('businesses', 'categories'));
    }

    public function create(): View
    {
        return view('admin.microbusinesses.create', [
            'business' => new Microbusiness([
                'status' => 'activo',
                'latitude' => 4.7110,
                'longitude' => -74.0721,
                'created_on_app_at' => now(),
            ]),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $business = Microbusiness::create($this->validated($request));
        $this->firestore->syncMicrobusiness($business);
        $this->audit('microbusiness_created', "Micronegocio creado: {$business->name}", 'microbusinesses', [
            'microbusiness_id' => $business->id,
        ]);

        return redirect()
            ->route('admin.microbusinesses.index')
            ->with('status', 'Micronegocio creado correctamente.');
    }

    public function edit(Microbusiness $microbusiness): View
    {
        return view('admin.microbusinesses.edit', ['business' => $microbusiness]);
    }

    public function update(Request $request, Microbusiness $microbusiness): RedirectResponse
    {
        $microbusiness->update($this->validated($request));
        $this->firestore->syncMicrobusiness($microbusiness);
        $this->audit('microbusiness_updated', "Micronegocio actualizado: {$microbusiness->name}", 'microbusinesses', [
            'microbusiness_id' => $microbusiness->id,
        ]);

        return redirect()
            ->route('admin.microbusinesses.index')
            ->with('status', 'Micronegocio actualizado correctamente.');
    }

    public function destroy(Microbusiness $microbusiness): RedirectResponse
    {
        $name = $microbusiness->name;
        $this->firestore->deleteMicrobusiness($microbusiness);
        $microbusiness->delete();
        $this->audit('microbusiness_deleted', "Micronegocio eliminado: {$name}", 'microbusinesses');

        return redirect()
            ->route('admin.microbusinesses.index')
            ->with('status', 'Micronegocio eliminado correctamente.');
    }

    private function validated(Request $request): array
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'category' => ['nullable', 'string', 'max:120'],
            'address' => ['nullable', 'string', 'max:255'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'maps_url' => ['nullable', 'url', 'max:2000'],
            'image_url' => ['nullable', 'url', 'max:2000'],
            'owner_id' => ['nullable', 'string', 'max:255'],
            'contact' => ['nullable', 'string', 'max:120'],
            'schedule' => ['nullable', 'string', 'max:120'],
            'status' => ['required', 'in:activo,inactivo'],
            'created_on_app_at' => ['nullable', 'date'],
            'average_rating' => ['nullable', 'numeric', 'between:0,5'],
            'ratings_count' => ['nullable', 'integer', 'min:0'],
        ]);

        $validated['created_on_app_at'] = $validated['created_on_app_at'] ?? now();
        $validated['favorites'] = [];
        $validated['ratings_count'] = (int) ($validated['ratings_count'] ?? 0);

        return $validated;
    }

    private function audit(string $action, string $description, string $module, ?array $metadata = null): void
    {
        AuditLog::log(
            auth()->id(),
            $action,
            $description,
            $module,
            request()->ip(),
            request()->userAgent(),
            $metadata,
        );
    }
}
