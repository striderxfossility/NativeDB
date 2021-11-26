<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Member;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Enum extends Model
{
    use HasFactory;
    use Cachable;

    protected $guarded = ['id'];

    public static function getEnum(string $name)
    {
        if($name == '')
            return 0;

        $enumID = \Cache::rememberForever('enum-' . $name, function() use ($name) {
            return self::whereName($name)->first() ? self::whereName($name)->first()->id : 0;
        });

        return $enumID;
    }

    public function members()
    {
        return $this->hasMany(Member::class);
    }
}
