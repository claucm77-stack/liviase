@props([
    'title',
    'value',
    'detail',
    'icon' => 'metric',
])

@php
    $icons = [
        'personas' => 'M17 20h5v-2a4 4 0 0 0-5.3-3.8M9 20H4v-2a4 4 0 0 1 5.3-3.8M15 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0Zm6 2a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z',
        'contenidos' => 'M4 5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v14l-4-2-4 2-4-2-4 2V5Z',
        'campos' => 'M4 6h16M4 12h16M4 18h10',
        'alertas' => 'M12 9v4m0 4h.01M10.3 3.9 2.7 17a2 2 0 0 0 1.7 3h15.2a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z',
    ];
@endphp

<div class="liviase-card p-5">
    <div class="flex items-start justify-between gap-4">
        <div>
            <p class="text-sm font-semibold text-gray-500">{{ $title }}</p>
            <p class="mt-2 text-3xl font-black text-gray-900">{{ $value }}</p>
            <p class="mt-1 text-sm text-gray-500">{{ $detail }}</p>
        </div>
        <span class="flex h-11 w-11 items-center justify-center rounded-lg bg-[#ffca55] text-[#193760]">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="{{ $icons[$icon] ?? $icons['campos'] }}" />
            </svg>
        </span>
    </div>
</div>
