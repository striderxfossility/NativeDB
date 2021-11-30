<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Code;
use App\Models\Type;

class CodeController extends Controller
{
    public function index()
    {
        $codes = Code::where("name", "!=", "0")->get();

        return view('pages.codes.index')->with('codes', $codes);
    }

    public function show(Code $code)
    {
        return view('pages.codes.show')->with('code', $code);
    }
    
    public function edit(Code $code)
    {
        return view('pages.codes.edit')->with('code', $code);
    }

    public function update(Code $code, Request $request)
    {
        if($request->code == "" && $request->native == "") {
            $code->delete();

            if($code->type == 0)
                return redirect()->route('codes.index');
        } else {
            if(isset($request->name))
                $code->update(['native' => $request->native, 'code' => $request->code, 'name' => $request->name]);
            else
                $code->update(['native' => $request->native, 'code' => $request->code]);
        }
        
        if($code->type != 0)
            return redirect()->route('types.show', Type::find(Type::getType($code->type))->id);

        return redirect()->route('codes.show', $code);
    }

    public function store(string $name, string $type, string $prop, string $method)
    {

        $code = Code::create([
            'name'      => $name,
            'type'      => $type,
            'prop'      => $prop,
            'method'    => $method,
            'code'      => ""
        ]);

        if ($name == '0') 
            return redirect()->route('codes.edit', $code);
        
        return redirect()->route('codes.index');
    }
}
