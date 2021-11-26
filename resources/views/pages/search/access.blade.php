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
    </main>

@include('layouts.footer')