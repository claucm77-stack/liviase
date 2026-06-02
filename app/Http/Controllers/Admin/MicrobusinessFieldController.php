<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MicrobusinessField;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class MicrobusinessFieldController extends Controller
{
    public function index(): View
    {
        $fields = MicrobusinessField::query()
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->paginate(15);

        return view('admin.microbusiness-fields.index', compact('fields'));
    }

    public function create(): View
    {
        return view('admin.microbusiness-fields.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'field_type' => ['required', 'in:text,textarea,number,select,checkbox,date,email,url'],
            'is_required' => ['nullable', 'boolean'],
            'options_text' => ['nullable', 'string'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $optionsJson = null;
        if (!empty($validated['options_text'])) {
            $options = array_values(array_filter(array_map('trim', explode(',', $validated['options_text']))));
            $optionsJson = $options ?: null;
        }

        MicrobusinessField::create([
            'name' => $validated['name'],
            'field_type' => $validated['field_type'],
            'is_required' => $request->boolean('is_required'),
            'options_json' => $optionsJson,
            'sort_order' => (int) ($validated['sort_order'] ?? 0),
            'is_active' => $request->boolean('is_active', true),
        ]);

        return redirect()
            ->route('admin.microbusiness-fields.index')
            ->with('status', 'Campo creado correctamente.');
    }

    public function edit(MicrobusinessField $microbusinessField): View
    {
        return view('admin.microbusiness-fields.edit', compact('microbusinessField'));
    }

    public function update(Request $request, MicrobusinessField $microbusinessField): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'field_type' => ['required', 'in:text,textarea,number,select,checkbox,date,email,url'],
            'is_required' => ['nullable', 'boolean'],
            'options_text' => ['nullable', 'string'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $optionsJson = null;
        if (!empty($validated['options_text'])) {
            $options = array_values(array_filter(array_map('trim', explode(',', $validated['options_text']))));
            $optionsJson = $options ?: null;
        }

        $microbusinessField->update([
            'name' => $validated['name'],
            'field_type' => $validated['field_type'],
            'is_required' => $request->boolean('is_required'),
            'options_json' => $optionsJson,
            'sort_order' => (int) ($validated['sort_order'] ?? 0),
            'is_active' => $request->boolean('is_active', true),
        ]);

        return redirect()
            ->route('admin.microbusiness-fields.index')
            ->with('status', 'Campo actualizado correctamente.');
    }

    public function destroy(MicrobusinessField $microbusinessField): RedirectResponse
    {
        $microbusinessField->delete();

        return redirect()
            ->route('admin.microbusiness-fields.index')
            ->with('status', 'Campo eliminado correctamente.');
    }
}
