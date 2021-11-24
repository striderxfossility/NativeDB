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
        <div class="mb-3 rounded overflow-hidden">
            @foreach (\App\Models\Method::whereTypeId($type->id)->get() as $method)
                <div class="grid grid-cols-4 hover:bg-gray-100 px-10 py-2">
                    <div class="col-span-2">
                        @if($method->params == '')
                        {{ $method->shortName }}()
                        @else
                            {{ $method->shortName }}(<br />
                            @php
                                if($method->params != '') {
                                    $json = json_decode($method->params);

                                    for ($i=0; $i < count($json); $i++) { 
                                        echo '<div class="px-10">';
                                            echo $json[$i]->name . ' : ' . $json[$i]->type . '';

                                            if($i != count($json) - 1)
                                                echo ',';

                                        echo '</div>';
                                    }
                                }
                            @endphp
                            )
                        @endif
                    </div>
                    <div class="">
                        : 
                        @if(str_contains($method->return, 'array'))
                            <span class="text-green-700">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                </svg>
                                {{ explode(':', $method->return)[0] }}</span>
                                : 
                                @if(explode(':', $method->return)[1] == 'handle' || explode(':', $method->return)[1] == 'whandle')
                                    <span class="text-pink-600">   
                                        {{ explode(':', $method->return)[1] }}
                                    </span>
                                @else
                                {{ explode(':', $method->return)[1] }}
                                @endif
                        @elseif(str_contains($method->return, 'handle') || str_contains($method->return, 'whandle'))
                            <span class="text-pink-600">   
                                {{ explode(':', $method->return)[0] }}
                            </span>
                        @else
                            {{ $method->return }}
                        @endif
                    </div>
                    <div>
                        @if(str_contains($method->return, 'handle') || str_contains($method->return, 'whandle'))
                            
                            @php($id = \App\Models\Type::whereName(explode(':', $method->return)[1])->first() != null ? \App\Models\Type::whereName(explode(':', $method->return)[1])->first()->id : '')
                            @php($name = \App\Models\Type::whereName(explode(':', $method->return)[1])->first() != null ? \App\Models\Type::whereName(explode(':', $method->return)[1])->first()->name : '')

                            <<a class="text-pink-600 hover:text-pink-300" href="/classes/{{ $id }}/show">{{ $name }}</a>>
                            
                        @else
                            {!! $method->return_type != 0 ? '<<a class="text-pink-600 hover:text-pink-300" href="/classes/' . \App\Models\Type::find($method->return_type)->id . '/show">' . \App\Models\Type::find($method->return_type)->name . '</a>>' : '' !!}
                        @endif
                    </div>
                </div>
            @endforeach
        </div>
    </main>

    @include('layouts.aside_classes')
    

@include('layouts.footer')