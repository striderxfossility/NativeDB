@include('layouts.header')

    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 pb-40 bg-white overflow-auto">
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                @php
                    if($tweakGroup->tweakGroup != null)
                    {
                        echo '<span class="text-green-600 cursor-pointer hover:text-green-500" onclick="window.location.href = \'' . route('tweakdb.show', $tweakGroup->tweakGroup->id) . '\'">' . $tweakGroup->tweakGroup->name . '</span>.';
                    }
                @endphp
{{ $tweakGroup->name }}
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($tweakGroup->tweakGroups as $subTweakGroup)
                    <div onclick="window.location.href = '{{ route('tweakdb.show', $subTweakGroup->id) }}';" class="hover:bg-gray-100 px-10 cursor-pointer">
                        <span class="text-green-600">Tweak Group</span> {{ $subTweakGroup->name }}
                    </div>
                @endforeach
            </div>
        </div>
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Values
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($tweakGroup->tweakValues as $tweakValue)
                    <div class="hover:bg-gray-100 px-10 cursor-pointer">
                        {{ $tweakValue->name }}
<x-markdown class="show-code">
```json
{!! $tweakValue->value !!}
```
                            </x-markdown>
                    </div>
                @endforeach
            </div>
        </div>
    </main>

@include('layouts.footer')