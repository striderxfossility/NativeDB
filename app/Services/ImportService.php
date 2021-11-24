<?php

namespace App\Services;

use App\Models\Type;

class ImportService 
{
    public static function get(Type $type) {

        if($type->cached)
            return $type;

        $type->type_id  = Type::getType($type->parent);
        $type->cached   = true;
        $type->parent   = '';

        $type->save();

        return $type;
    }
}