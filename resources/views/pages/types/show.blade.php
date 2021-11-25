@include('layouts.header')

<div class="flex-auto lg:flex lg:flex-row">

    @if(!env('APP_TESTS '))
        @include('layouts.aside_classes')
    @endif
    
    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
        <div class="mb-3 border-b border-gray-200 pb-1">
            <h1 class="text-xl text-purple-500">{{ $type->name }}</h1>
            <div class="flex flex-row items-start mt-px ml-4">
                @if(isset($type->type))
                    <span class="text-sm text-yellow-500">↳</span>
                    <a class="text-yellow-500 px-1 py-px hover:bg-gray-200 break-all tracking-tight transition duration-200" href="/classes/{{ $type->type->id }}/show">
                        {{ $type->type->name }}
                    </a>
                @endif
            </div>
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
        
        <h2 class="mb-4 border-b border-gray-200">Methods</h2>
        <div class="mb-3 rounded overflow-hidden">
            @foreach ($type->methods as $method)
                <div class="grid grid-cols-4 hover:bg-gray-100 px-10 py-4">
                    <div class="col-span-2">
                        {!! $method->functionNice !!}
                    </div>
                    <div class="">
                        {!! $method->returnNice !!}
                    </div>
                    <div>
                        {!! $method->returnTypeNice !!}
                    </div>
                </div>
            @endforeach
        </div>
    </main>
    
@include('layouts.footer')