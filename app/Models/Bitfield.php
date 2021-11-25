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

    public function members()
    {
        return $this->hasMany(Member::class);
    }
}
