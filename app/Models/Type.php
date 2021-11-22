<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Field;
use App\Models\Method;

class Type extends Model
{
    use HasFactory;

    public static function getType(string $name)
    {
        if($name == '')
            return 0;

        return self::whereName($name)->first() ? self::whereName($name)->first()->id : 0;
    }

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function fields()
    {
        return $this->hasMany(Field::class);
    }

    public function methods()
    {
        return $this->hasMany(Method::class);
    }
}
