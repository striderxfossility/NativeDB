@include('layouts.header')

    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Classes
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($types as $type)
                    <div onclick="window.location.href = '{{ route('types.show', $type) }}';" class="grid grid-cols-3 hover:bg-gray-100 px-10 cursor-pointer">
                        <div class="">
                            <span class="text-pink-600">CLASS</span> 
                            {{ $type->name }} 
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Enums
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($enums as $enum)
                    <div onclick="window.location.href = '{{ route('enums.show', $enum) }}';" class="grid grid-cols-3 hover:bg-gray-100 px-10 cursor-pointer">
                        <div class="">
                            <span class="text-purple-600">ENUM</span> 
                            {{ $enum->name }} 
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Bitfields
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($bitfields as $bitfield)
                    <div onclick="window.location.href = '{{ route('bitfields.show', $bitfield) }}';" class="grid grid-cols-3 hover:bg-gray-100 px-10 cursor-pointer">
                        <div class="">
                            <span class="text-yellow-600">BITFIELD</span> 
                            {{ $bitfield->name }} 
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </main>

@include('layouts.footer')