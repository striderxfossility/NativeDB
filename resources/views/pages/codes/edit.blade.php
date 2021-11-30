@include('layouts.header')

<form method="POST" class="m-10" action="{{ route('codes.update', $code) }}">
    @csrf
    
    @if($code->name != "0")
        <div class="mt-4">
            <div><label for="name" class="bg-white text-gray-600 px-1">Name</label></div>
            <input name="name" id="name" class="autoexpand tracking-wide py-2 px-4 mb-3 leading-relaxed appearance-none block w-full bg-gray-200 border border-gray-200 rounded focus:outline-none focus:bg-white focus:border-gray-500" type="text" value="{{ $code->name }}"/>
        </div>
    @endif

    <div class="mt-4">
        <div><label for="name" class="bg-white text-gray-600 px-1">Lua</label></div>
        <textarea rows="10" name="code" id="code" class="autoexpand tracking-wide py-2 px-4 mb-3 leading-relaxed appearance-none block w-full bg-gray-200 border border-gray-200 rounded focus:outline-none focus:bg-white focus:border-gray-500" type="text">{{ $code->code }}</textarea>
    </div>
    

    <div class="flex items-center justify-end mt-4">
        <button class="shadow bg-red-400 hover:bg-red-300 focus:shadow-outline focus:outline-none text-white font-bold py-2 px-4 rounded"
        type="submit">
            Save
        </button>
    </div>
</form>

@include('layouts.footer')