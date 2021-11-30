<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Prop;
use App\Models\Method;
use App\Models\Code;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Type extends Model
{
    use HasFactory;
    use Cachable;

    protected $guarded = ['id'];

    public static function getType(string $name)
    {
        if($name == '')
            return 0;

        $typeID = \Cache::rememberForever('type-' . $name, function() use ($name) {
            return self::whereName($name)->first() ? self::whereName($name)->first()->id : 0;
        });

        return $typeID;
    }

    public function code()
    {
        return $this->belongsTo(Code::class, 'name', 'type')->whereProp('0')->whereMethod('0');
    }

    public function type()
    {
        return $this->belongsTo(Type::class);
    }

    public function props()
    {
        return $this->hasMany(Prop::class);
    }

    public function methods()
    {
        return $this->hasMany(Method::class);
    }
}
