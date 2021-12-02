@include('layouts.header')

    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 pb-40 bg-white overflow-auto">
        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Tweak Groups
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($tweakgroups as $tweakgroup)
                    <div onclick="window.location.href = '{{ route('tweakdb.show', $tweakgroup->id) }}';" class="hover:bg-gray-100 px-10 cursor-pointer">
                        <span class="text-green-600">Tweak Group</span> {{ $tweakgroup->name }}
                    </div>
                @endforeach
            </div>
        </div>
    </main>

@include('layouts.footer')