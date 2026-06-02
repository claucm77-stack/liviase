<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PlatformSetting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PlatformSettingController extends Controller
{
    public function edit(): View
    {
        $settings = PlatformSetting::query()->firstOrCreate([], [
            'platform_name' => 'Mi Plataforma Educativa',
            'contact_email' => null,
            'support_whatsapp' => null,
            'about' => null,
            'maintenance_mode' => false,
        ]);

        return view('admin.settings.edit', compact('settings'));
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'platform_name' => ['required', 'string', 'max:150'],
            'contact_email' => ['nullable', 'email', 'max:180'],
            'support_whatsapp' => ['nullable', 'string', 'max:40'],
            'about' => ['nullable', 'string'],
            'maintenance_mode' => ['nullable', 'boolean'],
        ]);

        $settings = PlatformSetting::query()->firstOrCreate([], [
            'platform_name' => 'Mi Plataforma Educativa',
        ]);

        $settings->update([
            'platform_name' => $validated['platform_name'],
            'contact_email' => $validated['contact_email'] ?? null,
            'support_whatsapp' => $validated['support_whatsapp'] ?? null,
            'about' => $validated['about'] ?? null,
            'maintenance_mode' => (bool) ($validated['maintenance_mode'] ?? false),
        ]);

        return redirect()
            ->route('admin.settings.edit')
            ->with('status', 'Configuración actualizada correctamente.');
    }
}
