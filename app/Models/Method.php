<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Type;

class Method extends Model
{
    use HasFactory;

    public static function getArray(string $name, string $parameters, string $return, string $returnType, bool $static, string $code = '')
    {
        return [
            'name'          => $name,
            'parameters'    => $parameters,
            'return'        => $return,
            'return_type'   => Type::getType($returnType),
            'code'          => $code,
            'static'        => $static
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
