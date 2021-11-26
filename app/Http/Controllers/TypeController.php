<?php

namespace App\Http\Controllers;

use App\Models\Type;
use Illuminate\Http\Request;
use App\Services\ImportService;

class TypeController extends Controller
{
    public function index()
    {
        return view('pages.types.index');
    }

    public function show(Type $type)
    {
        $type = ImportService::get($type);

        $type = Type::whereId($type->id)
            ->with('type.type')
            ->with('props.returnType')
            ->with('props.returnEnum')
            ->with('methods.returnType')
            ->with('methods.returnEnum')
            ->with('methods.paramsArr.typeHead')
            ->firstOrFail();

        return view('pages.types.show')->with('type', $type);
    }
}
