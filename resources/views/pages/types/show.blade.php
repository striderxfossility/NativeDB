@include('layouts.header')

<div class="flex-auto lg:flex lg:flex-row">
    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
        <div class="mb-3 border-b border-gray-200 pb-1">
            <h1 class="text-xl">{{ $type->name }}</h1>
            <div class="flex flex-row items-start mt-px ml-4">
                <span class="text-sm">↳</span>
                <a class="px-1 py-px hover:bg-gray-200 break-all tracking-tight transition duration-200" href="/classes/{{ $type->type->id }}/show">
                    {{ $type->type->name }}
                </a>
            </div>
        </div>
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Fields
            </h2>
            <div id="blockLandingStimBroadcasting" class="flex flex-col xl:flex-row mb-3 rounded bg-gray-100 overflow-hidden">
                
            </div>
        </div>
        
        <h2 class="mb-4 border-b border-gray-200">Methods</h2>
        <div id="BroadcastLandingStim;StateContextStateGameScriptInterfacegamedataStimType" class="flex flex-col xl:flex-row mb-3 rounded bg-gray-100 overflow-hidden">
            
        </div>
    </main>

    @include('layouts.aside_classes')
    

@include('layouts.footer')