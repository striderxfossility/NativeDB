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
                </a>
            </div>

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
                </div>
            @endforeach
        </div>
    </main>
    
@include('layouts.footer')