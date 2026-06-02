@props(['active'])

@php
$classes = ($active ?? false)
            ? 'block w-full ps-3 pe-4 py-2 border-l-4 border-[#ffca55] text-start text-base font-semibold text-[#3c747a] bg-[#f7f7f6] focus:outline-none focus:text-[#193760] focus:bg-white focus:border-[#4c8d93] transition duration-150 ease-in-out'
            : 'block w-full ps-3 pe-4 py-2 border-l-4 border-transparent text-start text-base font-medium text-gray-600 hover:text-[#3c747a] hover:bg-gray-50 hover:border-[#4c8d93] focus:outline-none focus:text-[#3c747a] focus:bg-gray-50 focus:border-[#4c8d93] transition duration-150 ease-in-out';
@endphp

<a {{ $attributes->merge(['class' => $classes]) }}>
    {{ $slot }}
</a>
