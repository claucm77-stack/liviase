<button {{ $attributes->merge(['type' => 'submit', 'class' => 'inline-flex items-center px-4 py-2 bg-[#4c8d93] border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-[#3c747a] focus:bg-[#3c747a] active:bg-[#193760] focus:outline-none focus:ring-2 focus:ring-[#4c8d93] focus:ring-offset-2 transition ease-in-out duration-150']) }}>
    {{ $slot }}
</button>
