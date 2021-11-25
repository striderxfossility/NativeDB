<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Enum;
use App\Models\Bitfield;
use GeneaLabs\LaravelModelCaching\Traits\Cachable;

class Member extends Model
{
    use HasFactory;
    use Cachable;

    public function enum()
    {
        return $this->belongsTo(Enum::class);
    }

    public function bitfield()
    {
        return $this->belongsTo(Bitfield::class);
    }
}
