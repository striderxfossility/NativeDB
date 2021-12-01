@include('layouts.header')

<div class="flex-auto lg:flex lg:flex-row">

    @if(!env('APP_TESTS '))
        @include('layouts.aside_bitfields')
    @endif
    
    <main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 pb-40 bg-white overflow-auto">
        <div class="mb-3 border-b border-gray-200 pb-1">
            <h1 class="text-xl text-purple-500">{{ $bitfield->name }}</h1>
        </div>

        <div class="mb-4">
            <h2 class="mb-4 border-b border-gray-200">
                Members
            </h2>
            <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
                @foreach ($bitfield->members as $member)
                    <div class="grid grid-cols-3 hover:bg-gray-100 px-10">
                        <div class="">
                            <span class="text-red-400">INT</span> 
                            {{ $member->name }} 
                        </div>

                        <div class="">
                            {{ $member->value }} 
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </main>

@include('layouts.footer')