@include('layouts.header')

<main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
    <h2 class="mb-4 border-b border-gray-200">
        {{ $code->name }}
    </h2>

    <div class="col-span-3 code pb-2 pt-2 w-auto" style="position:relative;">
        <button onclick="copyCode{{ $code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
            <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
        </button>

        @auth
            <a href="/codes/{{ $code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
            </a>
        @endauth

        <script>
            function copyCode{{ $code->id }}() {
                var copyText = document.getElementById("copy-{{ $code->id }}")
                navigator.clipboard.writeText(copyText.innerHTML)
            }
        </script>
        
        <div style="display:none" id="copy-{{ $code->id }}">{{ $code->code }}</div>
        <x-markdown class="show-code">
```lua
{!! $code->code !!}
```
        </x-markdown>
    </div>
</main>

@include('layouts.footer')