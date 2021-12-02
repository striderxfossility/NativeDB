<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Type;
use App\Models\Enum;
use App\Models\Prop;
use App\Models\Method;
use App\Models\Bitfield;
use App\Models\Code;
use App\Models\TweakValue;

class SearchController extends Controller
{
    public function search(Request $request) 
    {
        if($request->q == "")
            return redirect()->route('/');

        $types          = Type::where('name', 'like', '%' . $request->q . '%')->get();
        $enums          = Enum::where('name', 'like', '%' . $request->q . '%')->get();
        $bitfields      = Bitfield::where('name', 'like', '%' . $request->q . '%')->get();
        $natives        = Code::where('native', 'like', '%' . $request->q . '%')->get();
        $tweakvalues    = TweakValue::where('name', 'like', '%' . $request->q . '%')->get();

        return view('pages.search.index')
            ->with('types', $types)
            ->with('enums', $enums)
            ->with('bitfields', $bitfields)
            ->with('natives', $natives)
            ->with('tweakvalues', $tweakvalues);
    }

    public function access(Type $type)
    {
        $types = Prop::where('return_type', $type->id)->with('type')->get()->pluck('type');

        $methods = Method::where('return_type', $type->id)->with('type')->get()->pluck('type');

        $types = $types->toBase()->merge($methods);

        return view('pages.search.access')->with('types', $types->unique());
    }
}
