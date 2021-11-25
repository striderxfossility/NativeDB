<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Enum;

class EnumController extends Controller
{
    public function all()
    {
        dump("test");
    }

    public function show(Enum $enum)
    {
        return view('pages.enums.show')->with('enum', $enum);
    }
}
