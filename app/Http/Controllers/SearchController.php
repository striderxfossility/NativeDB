<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Type;
use App\Models\Enum;
use App\Models\Bitfield;

class SearchController extends Controller
{
    public function search(Request $request) 
    {
        if($request->q == "")
            return redirect()->route('/');

        $types      = Type::where('name', 'like', '%' . $request->q . '%')->get();
        $enums      = Enum::where('name', 'like', '%' . $request->q . '%')->get();
        $bitfields  = Bitfield::where('name', 'like', '%' . $request->q . '%')->get();

        return view('pages.search.index')
            ->with('types', $types)
            ->with('enums', $enums)
            ->with('bitfields', $bitfields);
    }
}
