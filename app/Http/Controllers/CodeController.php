<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Code;
use App\Models\Type;

class CodeController extends Controller
{
    public function edit(Code $code)
    {
        return view('pages.codes.edit')->with('code', $code);
    }

    public function update(Code $code, Request $request)
    {
        if($request->code == "") {
            $code->delete();
        } else {
            $code->update(['code' => $request->code]);
        }
        
        return redirect()->route('types.show', Type::find(Type::getType($code->type))->id);
    }
}
