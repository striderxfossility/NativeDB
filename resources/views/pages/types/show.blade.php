@include('layouts.header')

<div class="flex-auto lg:flex lg:flex-row">

    @if(!env('APP_TESTS '))
        @include('layouts.aside_classes')
    @endif
    
    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
        <div class="mb-3 border-b border-gray-200 pb-1 pb-2">

            <div class="lg:flex flex-shrink-0 w-full h-8 px-4 border-b hidden mb-2">
                <a href="/search/{{ $type->id }}/access" class="text-gray-600 flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100">
                    Find wich class returns this class
                </a> | 
                <button id="codeButton" onclick="showAllCode()" class="text-gray-600 flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100">
                    CODE
                </button>
            </div>

            @if($type->code != null)
                <div class="code pb-2 pt-2 w-auto" style="position:relative; display:none">
                    <button onclick="copyCode{{ $type->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                    </button>

                    @auth
                        <a href="/codes/{{ $type->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                            <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                        </a>
                    @endauth

                    <script>
                        function copyCode{{ $type->code->id }}() {
                            var copyText = document.getElementById("copy-{{ $type->code->id }}")
                            navigator.clipboard.writeText(copyText.innerHTML)
                        }
                    </script>
                    
                    <div style="display:none" id="copy-{{ $type->code->id }}">{{ $type->code->code }}</div>
                        <x-markdown class="show-code">
```lua
{{ $type->code->code }}
```
                        </x-markdown>
                    </div>
            @endif

            <h1 class="text-xl text-purple-500">{{ $type->name }}</h1>

            @php ($headType = $type->type)
            @php ($i = 1)

            @while (isset($headType))
                <div class="flex flex-row items-start mt-px ml-{{ 4 * $i }}">
                    <span class="text-sm text-yellow-500">↳</span>
                    <a class="text-yellow-500 px-1 py-px hover:bg-gray-200 break-all tracking-tight transition duration-200" href="/classes/{{ $headType->id }}/show">
                        {{ $headType->name }}
                    </a>
                </div>
                @php ($headType = $headType->type)
                @php ($i++)
            @endwhile

        </div>
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Fields
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($type->props as $prop)
                    <div class="grid grid-cols-3 hover:bg-gray-100 px-10">
                        <div class="">
                            <span class="text-red-400">var</span> 
                            {{ $prop->name }} 
                        </div>
                        <div class="">
                            return : {!! $prop->returnNice !!}
                        </div>
                        <div>
                            {!! $prop->returnTypeNice !!}
                        </div>
                        @if($prop->code != null)
                            <div class="col-span-3 code pb-2 pt-2 w-auto" style="position:relative; display:none">
                                <button onclick="copyCode{{ $prop->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                    </svg>
                                </button>

                                @auth
                                    <a href="/codes/{{ $prop->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                        </svg>
                                    </a>
                                @endauth

                                @auth
                                    <button onclick="copyCode{{ $type->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                    </button>
                                @endauth

                                <script>
                                    function copyCode{{ $prop->code->id }}() {
                                        var copyText = document.getElementById("copy-{{ $prop->code->id }}")
                                        navigator.clipboard.writeText(copyText.innerHTML)
                                    }
                                </script>
                                
                                <div style="display:none" id="copy-{{ $prop->code->id }}">{{ $prop->code->code }}</div>
                                    <x-markdown class="show-code">
```lua
{{ $prop->code->code }}
```
                                    </x-markdown>
                                </div>
                        @endif
                    </div>
                @endforeach
            </div>
        </div>
        
        <h2 style="content-visibility: auto" class="mb-4 border-b border-gray-200">Methods</h2>
        <div style="content-visibility: auto" class="mb-3 rounded overflow-hidden">
            @foreach ($type->methods as $method)
                <div class="hover:bg-gray-100 px-10 py-4 relative">
                    <div class="">
                        {!! $method->functionNice !!}
                    </div>

                    <div class="absolute top-2 right-2 text-xs text-gray-400">
                        {{ $method->fullName }}
                    </div>

                    @if($method->code != null)
                            <div class="col-span-3 code pb-2 pt-2 w-auto" style="position:relative; display:none">
                                <button onclick="copyCode{{ $method->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                    </svg>
                                </button>

                                @auth
                                    <a href="/codes/{{ $method->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                        </svg>
                                    </a>
                                @endauth

                                <script>
                                    function copyCode{{ $method->code->id }}() {
                                        var copyText = document.getElementById("copy-{{ $method->code->id }}")
                                        navigator.clipboard.writeText(copyText.innerHTML)
                                    }
                                </script>
                                
                                <div style="display:none" id="copy-{{ $method->code->id }}">{{ $method->code->code }}</div>
                                    <x-markdown class="show-code">
```lua
{{ $method->code->code }}
```
                                    </x-markdown>
                                </div>
                        @endif
                </div>
            @endforeach
        </div>
    </main>

<script>
    let displayed = false
    
    if(document.getElementsByClassName("code").length == 0) {
        document.getElementById('codeButton').style.display = 'none';
    }
    

    function showAllCode() {
        const codes = document.getElementsByClassName("code");

        for (let index = 0; index < codes.length; index++) {
            const element = codes[index];

            if (displayed == false) {
                element.style.display = 'block'
            } else {
                element.style.display = 'none'
            }
        }

        if (displayed == false) {
            displayed = true
        } else {
            displayed = false
        }
    }
</script>
    
@include('layouts.footer')