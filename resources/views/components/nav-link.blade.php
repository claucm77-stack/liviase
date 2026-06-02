@props(['active'])

@php
$classes = ($active ?? false)
            ? 'inline-flex items-center px-1 pt-1 border-b-2 border-[#ffca55] text-sm font-semibold leading-5 text-gray-900 focus:outline-none focus:border-[#4c8d93] transition duration-150 ease-in-out'
            : 'inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium leading-5 text-gray-500 hover:text-[#3c747a] hover:border-[#4c8d93] focus:outline-none focus:text-[#3c747a] focus:border-[#4c8d93] transition duration-150 ease-in-out';
@endphp

<a {{ $attributes->merge(['class' => $classes]) }}>
    {{ $slot }}
</a>
