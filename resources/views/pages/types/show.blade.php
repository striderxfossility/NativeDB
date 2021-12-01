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

            @auth
                <a href="/code/{{ $type->id }}/create" class="p-2 pl-5 pr-5 bg-blue-500 text-gray-100 text-lg rounded-lg focus:border-4 border-blue-300">
                    upload entire swift
                </a>
            @endauth

            @if($type->code != null)
                <div class="code pb-2 pt-2 mt-6 w-auto" style="position:relative; display:none">

                    <script>
                        function ShowCode{{ $type->code->id }}(id) {
                            if (id == 0) {
                                document.getElementById('luacode-{{ $type->code->id }}').style.display = "block";
                                document.getElementById('nativecode-{{ $type->code->id }}').style.display = "none";
                            } else {
                                document.getElementById('luacode-{{ $type->code->id }}').style.display = "none";
                                document.getElementById('nativecode-{{ $type->code->id }}').style.display = "block";
                            }
                        }
                    </script>

                    @if($type->code->code != "")
                        <button onclick="ShowCode{{ $type->code->id }}(0)"  class="rounded-t-md px-2 absolute -top-4 left-0" style="background-color: #0d1117;">
                            <span class="text-white">lua</span>
                        </button>
                    @endif

                    @if($type->code->native != "")
                        <button onclick="ShowCode{{ $type->code->id }}(1)"  class="rounded-t-md px-2 absolute -top-4 left-12" style="background-color: #0d1117;">
                            <span class="text-white">native</span>
                        </button>
                    @endif

                    @auth
                        <a href="/codes/{{ $type->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                            <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                        </a>
                    @endauth

                    <div id="luacode-{{ $type->code->id }}" style="display:block;">

                        <button onclick="copyCodelua{{ $type->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                            <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                        </button>

                        <script>
                            function copyCodelua{{ $type->code->id }}() {
                                var copyText = document.getElementById("copylua-{{ $type->code->id }}")
                                navigator.clipboard.writeText(copyText.innerHTML)
                            }
                        </script>
                        
                        <div style="display:none" id="copylua-{{ $type->code->id }}">{{ $type->code->code }}</div>
                            <x-markdown class="show-code">
```lua
{!! $type->code->code !!}
```
                            </x-markdown>
                    </div>

                    <div id="nativecode-{{ $type->code->id }}" style="display:none;">

                        <button onclick="copyCodeNative{{ $type->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                            <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                        </button>

                        <script>
                            function copyCodeNative{{ $type->code->id }}() {
                                var copyText = document.getElementById("copynative-{{ $type->code->id }}")
                                navigator.clipboard.writeText(copyText.innerHTML)
                            }
                        </script>
                        
                        <div style="display:none" id="copynative-{{ $type->code->id }}">{{ $type->code->native }}</div>
                            <x-markdown class="show-code">
```lua
{!! $type->code->native !!}
```
                            </x-markdown>
                    </div>
                </div>
                <script>
                    if(document.getElementById('copylua-{{ $type->code->id }}').innerHTML == "") {
                        document.getElementById('luacode-{{ $type->code->id }}').style.display = "none";
                        document.getElementById('nativecode-{{ $type->code->id }}').style.display = "block";
                    }
                </script>
            @else
                @auth
                    <a href="/codes/0/{{ $type->name }}/0/0/store" title="Add new lua" class="cursor-pointer" style="background-color: #0d1117;">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                    </a>
                @endauth
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
                    <div class="grid grid-cols-3 hover:bg-gray-100 px-10 relative">
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
                            <div class="code pb-2 pt-2 mt-6 w-auto" style="position:relative; display:none">

                                <script>
                                    function ShowCode{{ $prop->code->id }}(id) {
                                        if (id == 0) {
                                            document.getElementById('luacode-{{ $prop->code->id }}').style.display = "block";
                                            document.getElementById('nativecode-{{ $prop->code->id }}').style.display = "none";
                                        } else {
                                            document.getElementById('luacode-{{ $prop->code->id }}').style.display = "none";
                                            document.getElementById('nativecode-{{ $prop->code->id }}').style.display = "block";
                                        }
                                    }
                                </script>

                                @if($prop->code->code != "")
                                    <button onclick="ShowCode{{ $prop->code->id }}(0)"  class="rounded-t-md px-2 absolute -top-4 left-0" style="background-color: #0d1117;">
                                        <span class="text-white">lua</span>
                                    </button>
                                @endif

                                @if($prop->code->native != "")
                                    <button onclick="ShowCode{{ $prop->code->id }}(1)"  class="rounded-t-md px-2 absolute -top-4 left-12" style="background-color: #0d1117;">
                                        <span class="text-white">native</span>
                                    </button>
                                @endif

                                @auth
                                    <a href="/codes/{{ $prop->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                        </svg>
                                    </a>
                                @endauth

                                <div id="luacode-{{ $prop->code->id }}" style="display:block;">

                                    <button onclick="copyCodelua{{ $prop->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                    </button>

                                    <script>
                                        function copyCodelua{{ $prop->code->id }}() {
                                            var copyText = document.getElementById("copylua-{{ $prop->code->id }}")
                                            navigator.clipboard.writeText(copyText.innerHTML)
                                        }
                                    </script>
                                    
                                    <div style="display:none" id="copylua-{{ $prop->code->id }}">{{ $prop->code->code }}</div>
                                        <x-markdown class="show-code">
```lua
{!! $type->code->code !!}
```
                                        </x-markdown>
                                </div>

                                <div id="nativecode-{{ $prop->code->id }}" style="display:none;">

                                    <button onclick="copyCodeNative{{ $prop->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                        </svg>
                                    </button>

                                    <script>
                                        function copyCodeNative{{ $prop->code->id }}() {
                                            var copyText = document.getElementById("copynative-{{ $prop->code->id }}")
                                            navigator.clipboard.writeText(copyText.innerHTML)
                                        }
                                    </script>
                                    
                                    <div style="display:none" id="copynative-{{ $prop->code->id }}">{{ $prop->code->native }}</div>
                                        <x-markdown class="show-code">
```lua
{!! $prop->code->native !!}
```
                                        </x-markdown>
                                </div>
                            </div>
                            <script>
                                if(document.getElementById('copylua-{{ $prop->code->id }}').innerHTML == "") {
                                    document.getElementById('luacode-{{ $prop->code->id }}').style.display = "none";
                                    document.getElementById('nativecode-{{ $prop->code->id }}').style.display = "block";
                                }
                            </script>
                        @else
                            @auth
                                <a href="/codes/0/{{ $type->name }}/{{ $prop->name }}/0/store" title="Add new lua" class="cursor-pointer absolute top-0 left-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                    </svg>
                                </a>
                            @endauth
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
                        <div class="code pb-2 pt-2 mt-6 w-auto" style="position:relative; display:none">

                            <script>
                                function ShowCode{{ $method->code->id }}(id) {
                                    if (id == 0) {
                                        document.getElementById('luacode-{{ $method->code->id }}').style.display = "block";
                                        document.getElementById('nativecode-{{ $method->code->id }}').style.display = "none";
                                    } else {
                                        document.getElementById('luacode-{{ $method->code->id }}').style.display = "none";
                                        document.getElementById('nativecode-{{ $method->code->id }}').style.display = "block";
                                    }
                                }
                            </script>

                            @if($method->code->code != "")
                                <button onclick="ShowCode{{ $method->code->id }}(0)"  class="rounded-t-md px-2 absolute -top-4 left-0" style="background-color: #0d1117;">
                                    <span class="text-white">lua</span>
                                </button>
                            @endif

                            @if($method->code->native != "")
                                <button onclick="ShowCode{{ $method->code->id }}(1)"  class="rounded-t-md px-2 absolute -top-4 left-12" style="background-color: #0d1117;">
                                    <span class="text-white">native</span>
                                </button>
                            @endif

                            @auth
                                <a href="/codes/{{ $method->code->id }}/edit" title="Copy" class="cursor-pointer p-2 absolute top-2 right-10" style="background-color: #0d1117;">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                    </svg>
                                </a>
                            @endauth

                            <div id="luacode-{{ $method->code->id }}" style="display:block;">

                                <button onclick="copyCodelua{{ $method->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                    </svg>
                                </button>

                                <script>
                                    function copyCodelua{{ $method->code->id }}() {
                                        var copyText = document.getElementById("copylua-{{ $method->code->id }}")
                                        navigator.clipboard.writeText(copyText.innerHTML)
                                    }
                                </script>
                                
                                <div style="display:none" id="copylua-{{ $method->code->id }}">{{ $method->code->code }}</div>
                                    <x-markdown class="show-code">
```lua
{!! $method->code->code !!}
```
                                    </x-markdown>
                            </div>

                            <div id="nativecode-{{ $method->code->id }}" style="display:none;">

                                <button onclick="copyCodeNative{{ $method->code->id }}()" title="Copy" class="p-2 absolute top-2 right-0" style="background-color: #0d1117;">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="text-white h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                    </svg>
                                </button>

                                <script>
                                    function copyCodeNative{{ $method->code->id }}() {
                                        var copyText = document.getElementById("copynative-{{ $method->code->id }}")
                                        navigator.clipboard.writeText(copyText.innerHTML)
                                    }
                                </script>
                                
                                <div style="display:none" id="copynative-{{ $method->code->id }}">{{ $method->code->native }}</div>
                                    <x-markdown class="show-code">
```lua
{!! $method->code->native !!}
```
                                    </x-markdown>
                            </div>
                        </div>
                        <script>
                            if(document.getElementById('copylua-{{ $method->code->id }}').innerHTML == "") {
                                document.getElementById('luacode-{{ $method->code->id }}').style.display = "none";
                                document.getElementById('nativecode-{{ $method->code->id }}').style.display = "block";
                            }
                        </script>
                    @else
                    @auth
                        <a href="/codes/0/{{ $type->name }}/0/{{ $method->fullName }}/store" title="Add new lua" class="cursor-pointer absolute top-4 left-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </a>
                    @endauth
                    @endif
                </div>
            @endforeach
        </div>
    </main>

<script>
    console.log(getCookie("displayed"))
    if(getCookie("displayed") == null) {
        setCookie("displayed","false",30);
    }
    
    if(document.getElementsByClassName("code").length == 0) {
        document.getElementById('codeButton').style.display = 'none';
    }

    function showAllCode() {
        const codes = document.getElementsByClassName("code");

        for (let index = 0; index < codes.length; index++) {
            const element = codes[index];

            if (getCookie("displayed") == "false") {
                element.style.display = 'block'
            } else {
                element.style.display = 'none'
            }
        }

        if (getCookie("displayed") == "false") {
            setCookie("displayed","true",30);
        } else {
            setCookie("displayed","false",30);
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        if (getCookie("displayed") == "true") {
            const codes = document.getElementsByClassName("code");

            for (let index = 0; index < codes.length; index++) {
                const element = codes[index];
                element.style.display = 'block'
            }
        }
    })
</script>
    
@include('layouts.footer')