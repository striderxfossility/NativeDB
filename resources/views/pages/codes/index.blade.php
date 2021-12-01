@include('layouts.header')
<main class="flex-grow min-w-0 h-full min-h-full max-h-0 px-4 sm:px-6 xl:px-8 py-7 bg-white overflow-auto">
    <div class="mb-4">
        @auth
            <div class="w-10">
                <a href="/codes/new/0/0/0/store" title="Add new lua" class="cursor-pointer">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                </a>
            </div>
        @endauth
        <h2 class="mb-4 border-b border-gray-200">
            Lua codes database
        </h2>
        <div id="blockLandingStimBroadcasting" class="mb-3 rounded overflow-hidden">
            @foreach ($codes as $code)
                <div onclick="window.location.href = '{{ route('codes.show', $code) }}';" class="hover:bg-gray-100 px-10 cursor-pointer">
                    <span class="text-yellow-600">LUA</span> 
                    {{ $code->name }} 
                </div>
            @endforeach
        </div>
    </div>
</main>
@include('layouts.footer')