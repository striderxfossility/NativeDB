<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Bitfield;

class BitfieldController extends Controller
{
    public function index()
    {
        return view('pages.bitfields.index');
    }

    public function show(Bitfield $bitfield)
    {
        return view('pages.bitfields.show')->with('bitfield', $bitfield);
    }
}
