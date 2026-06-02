@props(['disabled' => false])

<input @disabled($disabled) {{ $attributes->merge(['class' => 'border-gray-300 focus:border-[#4c8d93] focus:ring-[#4c8d93] rounded-md shadow-sm']) }}>
