<?php

namespace App\Http\Controllers;

use App\Models\Type;
use Illuminate\Http\Request;
use App\Services\ImportService;

class TypeController extends Controller
{
    public function all()
    {
        dump("test");
    }

    public function show(Type $type)
    {
        $type = ImportService::get($type);

        $type = Type::whereId($type->id)->with('type')->with('props.returnType')->with('methods.returnType')->with('methods.paramsArr.typeHead')->firstOrFail();

        return view('pages.types.show')->with('type', $type);
    }
}
