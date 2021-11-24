@include('layouts.header')

<div class="flex-auto lg:flex lg:flex-row">
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
                @foreach (\App\Models\Prop::whereTypeId($type->id)->get() as $prop)
                    <div class="grid grid-cols-3 hover:bg-gray-100 px-10">
                        <div class="">
                            <span class="text-red-400">var</span> 
                            {{ $prop->name }} 
                        </div>
                        <div class="">
                            : 
                            @if(str_contains($prop->return, 'array'))
                                <span class="text-green-700">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                    </svg>
                                    {{ explode(':', $prop->return)[0] }}</span>
                                    : 
                                    @if(explode(':', $prop->return)[1] == 'handle' || explode(':', $prop->return)[1] == 'whandle')
                                        <span class="text-pink-600">   
                                            {{ explode(':', $prop->return)[1] }}
                                        </span>
                                    @else
                                    {{ explode(':', $prop->return)[1] }}
                                    @endif
                            @elseif($prop->return == 'handle' || $prop->return == 'whandle')
                                <span class="text-pink-600">   
                                    {{ $prop->return }}
                                </span>
                            @else
                                {{ $prop->return }}
                            @endif
                        </div>
                        <div>
                            {!! $prop->return_type != '' ? '<<a class="text-pink-600 hover:text-pink-300" href="/classes/' . \App\Models\Type::find($prop->return_type)->id . '/show">' . \App\Models\Type::find($prop->return_type)->name . '</a>>' : '' !!}
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
        
        <h2 class="mb-4 border-b border-gray-200">Methods</h2>
        <div id="BroadcastLandingStim;StateContextStateGameScriptInterfacegamedataStimType" class="flex flex-col xl:flex-row mb-3 rounded bg-gray-100 overflow-hidden">
            
        </div>
    </main>

    @include('layouts.aside_classes')
    

@include('layouts.footer')