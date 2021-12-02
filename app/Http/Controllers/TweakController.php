<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\TweakGroup;

class TweakController extends Controller
{
    public function index() 
    {
        $tweakgroups = TweakGroup::whereTweakGroupName('')->get();

        return view('pages.tweakdb.index')->with('tweakgroups', $tweakgroups);
    }

    public function show(TweakGroup $tweakGroup)
    {
        return view('pages.tweakdb.show')->with('tweakGroup', $tweakGroup);
    }
}
