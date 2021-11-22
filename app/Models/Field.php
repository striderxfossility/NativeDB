<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;

class Field extends Model
{
    use HasFactory;

    public static function getArray(string $name, string $return, string $returnType, bool $private, string $code = '')
    {
        if($code == '')
            $code = '{main}.' . $name;

        return [
            'name'          => $name,
            'return'        => $return,
            'return_type'   => Type::getType($returnType),
            'code'          => $code,
            'private'       => $private
        ];
    }

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function returnType()
    {
        return $this->belongsTo(Type::class);
    }
}
