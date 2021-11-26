<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MOO</title>
        <link href="https://unpkg.com/tailwindcss@^2/dist/tailwind.min.css" rel="stylesheet">
    </head>
    <body class="relative antialiased text-base text-black font-mono">
        <div id="__next">
            <div class="h-screen overflow-hidden">
                <div class="flex flex-col h-full">

                    <header class="flex flex-shrink-0 items-center w-full h-12 pl-4 pr-1 py-1.5 bg-black-pearl text-white">
                        <button class="flex items-center lg:hidden mr-4 sm:mr-6 hover:text-gray-200 transition duration-100">
                            <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="bars" class="svg-inline--fa fa-bars fa-w-14 " role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
                                <path fill="currentColor" d="M16 132h416c8.837 0 16-7.163 16-16V76c0-8.837-7.163-16-16-16H16C7.163 60 0 67.163 0 76v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16z"></path>
                            </svg>
                        </button>
                        <a href="/">
                            <span class="text-2xl hover:text-gray-200 transition duration-100">NativeDB</span>
                        </a>
                        <div class="lg:flex-shrink-0 w-8 lg:w-[185px]"></div>
                        <div class="flex items-center w-full h-full pl-2 bg-[#0d1117] hover:bg-[#161d27] border border-gray-700 rounded text-gray-300 hover:text-gray-100">
                            <button>
                                <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="search" class="svg-inline--fa fa-search fa-w-16 mr-4" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                                    <path fill="currentColor" d="M505 442.7L405.3 343c-4.5-4.5-10.6-7-17-7H372c27.6-35.3 44-79.7 44-128C416 93.1 322.9 0 208 0S0 93.1 0 208s93.1 208 208 208c48.3 0 92.7-16.4 128-44v16.3c0 6.4 2.5 12.5 7 17l99.7 99.7c9.4 9.4 24.6 9.4 33.9 0l28.3-28.3c9.4-9.4 9.4-24.6.1-34zM208 336c-70.7 0-128-57.2-128-128 0-70.7 57.2-128 128-128 70.7 0 128 57.2 128 128 0 70.7-57.2 128-128 128z"></path>
                                </svg>
                            </button>
                            <input type="search" class="w-full h-full bg-[#0d1117] hover:bg-[#161d27] placeholder-gray-100 focus:placeholder-gray-500 outline-none" placeholder="Search" value="" autofocus="" data-com.bitwarden.browser.user-edited="yes">
                        </div>
                    </header>
                    
                    <div class="lg:flex flex-shrink-0 w-full h-8 px-4 bg-gray-100 border-b hidden">
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
                    </div>