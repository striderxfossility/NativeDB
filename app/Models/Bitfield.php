<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Member;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Bitfield extends Model
{
    use HasFactory;
    use Cachable;

    protected $guarded = ['id'];

    public static function getBitfield(string $name)
    {
        if($name == '')
            return 0;

        $bitfieldID = \Cache::rememberForever('bitfield-' . $name, function() use ($name) {
            return self::whereName($name)->first() ? self::whereName($name)->first()->id : 0;
        });

        return $bitfieldID;
    }

    public function members()
    {
        return $this->hasMany(Member::class);
    }
}
