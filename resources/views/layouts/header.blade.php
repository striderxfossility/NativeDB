<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MOO</title>
        <link href="https://unpkg.com/tailwindcss@^2/dist/tailwind.min.css" rel="stylesheet">
        <style>
            .shiki {
                padding: 5px;
            }
        </style>
    </head>
    <script>
        function setCookie(name,value,days) {
            var expires = "";
            if (days) {
                var date = new Date();
                date.setTime(date.getTime() + (days*24*60*60*1000));
                expires = "; expires=" + date.toUTCString();
            }
            document.cookie = name + "=" + (value || "")  + expires + "; path=/";
        }
        function getCookie(name) {
            var nameEQ = name + "=";
            var ca = document.cookie.split(';');
            for(var i=0;i < ca.length;i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1,c.length);
                if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
            }
            return null;
        }
    </script>
    <body class="relative antialiased text-base text-black font-mono">
        <div id="__next">
            <div class="h-screen overflow-hidden">
                <div class="flex flex-col h-full">

                    <header class="flex flex-shrink-0 items-center w-full h-12 pl-4 pr-1 py-1.5 bg-black text-white">
                        <button class="flex items-center lg:hidden mr-4 sm:mr-6 hover:text-gray-200 transition duration-100">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </button>
                        <a href="/">
                            <span class="text-2xl hover:text-gray-200 transition duration-100">NativeDB</span>
                        </a>
                        <div class="lg:flex-shrink-0 w-8 lg:w-[185px]"></div>
                        <div class="flex items-center w-full h-full pl-2 bg-black hover:bg-[#161d27] border border-gray-700 rounded text-gray-300 hover:text-gray-100">
                            <form action="{{ route('search') }}" class="contents" method="POST">
                                @csrf
                                <button>
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                    </svg>
                                </button>
                                <input type="input" class="w-full pl-5 h-full bg-black placeholder-gray-100 focus:placeholder-gray-500 outline-none" placeholder="Search" value="" id="q" name="q" autofocus="">
                            </form>
                        </div>
                    </header>
                    
                    <div class="lg:flex flex-shrink-0 w-full h-8 px-4 bg-gray-100 border-b hidden">
                        @auth
                        <span class="text-green-700 flex items-center h-8 mr-0.5 text-xs text-gray-500 pr-5">Logged in!</span>
                        @endauth

                        <span class="flex items-center h-8 mr-0.5 text-xs text-gray-500">Type:</span>
                        <a href="/classes" class="text-pink-600 flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100 {{ str_contains(Route::currentRouteName(), 'types') ? 'bg-gray-200' : '' }}">
                            Class
                        </a>
                        <a href="/enums" class="text-purple-500 flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100 {{ str_contains(Route::currentRouteName(), 'enums') ? 'bg-gray-200' : '' }}">
                            Enum
                        </a>
                        <a href="/bitfields" class="text-yellow-500 flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100 {{ str_contains(Route::currentRouteName(), 'bitfields') ? 'bg-gray-200' : '' }}">
                            Bitfield
                        </a>
                        <a href="/tweakdb" class="flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100 {{ str_contains(Route::currentRouteName(), 'tweakdb') ? 'bg-gray-200' : '' }}">
                            TweakDB
                        </a>
                        <a href="/scripts" class="flex items-center h-8 px-2 py-1 hover:bg-gray-200 text-xs transition duration-100 {{ str_contains(Route::currentRouteName(), 'code') ? 'bg-gray-200' : '' }}">
                            Scripts
                        </a>
                    </div>